type gateway = {
  gateway_name: string,
  distribution: int,
  disableFallback: bool,
}

type formState = CreateConfig | EditConfig | ViewConfig
