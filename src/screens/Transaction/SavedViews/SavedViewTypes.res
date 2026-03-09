type savedView = {
  view_name: string,
  entity: string,
  filters: JSON.t,
  created_at: string,
  updated_at: string,
}

type savedViewsResponse = {
  count: int,
  views: array<savedView>,
}
