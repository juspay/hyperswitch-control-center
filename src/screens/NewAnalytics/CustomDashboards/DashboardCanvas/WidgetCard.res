let attachResizeHandlers: (
  Dom.element,
  int,
  int,
  (int, int) => unit,
) => unit = %raw(`
  function(container, currentW, currentH, onResizeEnd) {
    container.querySelectorAll('.resize-handle').forEach(function(el) { el.remove() });

    function getGridEl() {
      var node = container.parentElement;
      for (var i = 0; i < 8 && node; i++) {
        if (node.classList && node.classList.contains('dashboard-grid')) return node;
        node = node.parentElement;
      }
      return null;
    }

    var MIN_W = 2, MAX_W = 12, MIN_H = 2, MAX_H = 10, H_UNIT = 80;

    function makeHandle(cls, cursor, axis) {
      var el = document.createElement('div');
      el.className = 'resize-handle ' + cls;
      el.style.cssText = 'position:absolute;z-index:10;cursor:' + cursor + ';';
      if (axis === 'x') { el.style.top='0';el.style.right='-4px';el.style.width='8px';el.style.height='100%'; }
      else if (axis === 'y') { el.style.bottom='-4px';el.style.left='0';el.style.height='8px';el.style.width='100%'; }
      else { el.style.bottom='-4px';el.style.right='-4px';el.style.width='18px';el.style.height='18px'; }

      el.addEventListener('mouseenter', function() { el.style.background='rgba(59,130,246,0.3)'; });
      el.addEventListener('mouseleave', function() { el.style.background='transparent'; });

      el.addEventListener('mousedown', function(e) {
        e.preventDefault();
        e.stopPropagation();
        var startX = e.clientX, startY = e.clientY;
        var gridEl = getGridEl();
        var gridW = gridEl ? gridEl.getBoundingClientRect().width : 1200;
        var oneCol = gridW / 12;

        // Source of truth: state values passed in
        var w = currentW, h = currentH;
        var wPx = oneCol * w, hPx = h * H_UNIT;
        var minWPx = oneCol * MIN_W, maxWPx = oneCol * MAX_W;
        var minHPx = MIN_H * H_UNIT, maxHPx = MAX_H * H_UNIT;

        // Snap container to state dimensions at drag start
        container.style.height = hPx + 'px';
        container.style.minHeight = '0px';
        container.style.overflow = 'hidden';
        container.style.outline = '2px solid #3b82f6';
        container.style.outlineOffset = '2px';
        container.style.transition = 'none';
        document.body.style.cursor = cursor;
        document.body.style.userSelect = 'none';

        var label = container.querySelector('.size-label');

        function onMove(ev) {
          var dx = ev.clientX - startX, dy = ev.clientY - startY;
          if (axis === 'x' || axis === 'xy') {
            var newWPx = Math.max(minWPx, Math.min(maxWPx, wPx + dx));
            container.style.width = newWPx + 'px';
            w = Math.max(MIN_W, Math.min(MAX_W, Math.round(newWPx / oneCol)));
          }
          if (axis === 'y' || axis === 'xy') {
            var newHPx = Math.max(minHPx, Math.min(maxHPx, hPx + dy));
            container.style.height = newHPx + 'px';
            h = Math.max(MIN_H, Math.min(MAX_H, Math.round(newHPx / H_UNIT)));
          }
          if (label) {
            label.textContent = w + '/12 \u00d7 ' + h + 'h';
            label.style.color = '#2563eb';
            label.style.fontWeight = '600';
          }
        }

        function onUp() {
          document.removeEventListener('mousemove', onMove);
          document.removeEventListener('mouseup', onUp);
          document.body.style.cursor = '';
          document.body.style.userSelect = '';
          container.style.outline = '';
          container.style.outlineOffset = '';
          container.style.overflow = '';
          container.style.transition = '';
          // Keep height set until React re-renders with new value
          container.style.height = (h * H_UNIT) + 'px';
          container.style.minHeight = (h * H_UNIT) + 'px';
          container.style.width = '';
          if (label) { label.style.color = ''; label.style.fontWeight = ''; }
          onResizeEnd(w, h);
        }

        document.addEventListener('mousemove', onMove);
        document.addEventListener('mouseup', onUp);
      });
      return el;
    }

    container.style.position = 'relative';
    container.appendChild(makeHandle('r-right','ew-resize','x'));
    container.appendChild(makeHandle('r-bottom','ns-resize','y'));
    container.appendChild(makeHandle('r-corner','nwse-resize','xy'));

    // Store abort function for cleanup during mid-drag unmount
    container.__abortResize = function() {
      document.body.style.cursor = '';
      document.body.style.userSelect = '';
      container.style.outline = '';
      container.style.outlineOffset = '';
      container.style.transition = '';
    };
  }
`)

let cleanupResizeHandlers: Dom.element => unit = %raw(`
  function(container) {
    // Abort any in-flight drag to prevent memory leak
    if (container.__abortResize) {
      container.__abortResize();
      container.__abortResize = null;
    }
    container.querySelectorAll('.resize-handle').forEach(function(el) { el.remove() });
    container.style.outline = '';
    container.style.width = '';
    container.style.height = '';
    container.style.minHeight = '';
    container.style.overflow = '';
  }
`)

@react.component
let make = (
  ~widget: CustomDashboardTypes.widget,
  ~isEditMode,
  ~onEdit=() => (),
  ~onRemove=() => (),
  ~onResize=(~w as _: int, ~h as _: int) => (),
  ~dragHandleProps=?,
) => {
  let borderClass = isEditMode ? "border-2 border-dashed border-blue-300 rounded-lg" : ""
  let cardRef = React.useRef(Nullable.null)
  let heightPx = widget.position.h * 80

  // Edit mode uses fixed height for resize stability; view mode allows content expansion
  let cardStyle = ReactDOM.Style.make(
    ~height=isEditMode ? `${heightPx->Int.toString}px` : "auto",
    ~minHeight=isEditMode ? "auto" : `${heightPx->Int.toString}px`,
    ~overflow=isEditMode ? "hidden" : "visible",
    (),
  )

  // Attach resize handles — re-runs when widget size changes (after resize end)
  React.useEffect(() => {
    switch cardRef.current->Nullable.toOption {
    | Some(el) =>
      if isEditMode {
        let cb = (w, h) => onResize(~w, ~h)
        attachResizeHandlers(el, widget.position.w, widget.position.h, cb)
        Some(() => cleanupResizeHandlers(el))
      } else {
        cleanupResizeHandlers(el)
        None
      }
    | None => None
    }
  }, (isEditMode, widget.position.w, widget.position.h))

  <InsightsHelper.Card>
    <div ref={cardRef->ReactDOM.Ref.domRef} className={borderClass} style={cardStyle}>
      <div className="flex items-center justify-between px-4 pt-3 pb-1">
        <div className="flex items-center gap-2">
          {if isEditMode {
            switch dragHandleProps {
            | Some(props) =>
              React.cloneElement(
                <span className="cursor-grab text-gray-400 text-lg select-none">
                  {React.string({`\u2630`})}
                </span>,
                props,
              )
            | None =>
              <span className="cursor-grab text-gray-400 text-lg select-none">
                {React.string({`\u2630`})}
              </span>
            }
          } else {
            React.null
          }}
          <p className="text-base font-semibold text-jp-gray-900 dark:text-white">
            {React.string(widget.widgetName)}
          </p>
          {if isEditMode {
            <span className="text-xs ml-2 text-gray-400 size-label">
              {React.string(
                `${widget.position.w->Int.toString}/12 \u00d7 ${widget.position.h->Int.toString}h`,
              )}
            </span>
          } else {
            React.null
          }}
        </div>
        {if isEditMode {
          <div className="flex items-center gap-2">
            <button
              className="p-1.5 rounded-md hover:bg-gray-100 text-gray-500 hover:text-blue-600 transition-colors"
              title="Edit widget"
              onClick={_ => onEdit()}>
              <Icon name="nd-pencil-edit-box" size=16 />
            </button>
            <button
              className="p-1.5 rounded-md hover:bg-red-50 text-red-400 hover:text-red-600 transition-colors"
              title="Remove widget"
              onClick={_ => onRemove()}>
              <Icon name="nd-cross" size=16 />
            </button>
          </div>
        } else {
          // View mode: no toggle buttons (removed as not useful)
          React.null
        }}
      </div>
      // Chart area with light blue background (matching mockup design)
      // [class*="highcharts-background"] makes Highcharts SVG background transparent
      <div
        className="mx-4 mb-4 rounded-lg overflow-hidden chart-bg-gradient"
        style={ReactDOM.Style.make(
          ~background="linear-gradient(180deg, #eff6ff 0%, #f0f9ff 40%, #ffffff 100%)",
          (),
        )}>
        <GenericChartRenderer widget />
      </div>
    </div>
  </InsightsHelper.Card>
}
