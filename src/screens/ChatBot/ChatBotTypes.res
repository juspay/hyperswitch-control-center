type response = {
  summary: string,
  markdown: string,
  responseTime: option<float>,
}
type chat = {
  message: string,
  response: response,
}
