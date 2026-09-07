open BlocklistUtils
open Typography

module CountCard = {
  @react.component
  let make = (~title, ~count) => {
    <section className="h-full border border-nd_gray-200 rounded-lg bg-white p-4">
      <p className={`text-nd_gray-500 ${body.sm.medium}`}> {title->React.string} </p>
      <p className={`text-nd_gray-800 mt-1 ${heading.md.semibold}`}>
        {count->formatBlocklistCount->React.string}
      </p>
    </section>
  }
}
