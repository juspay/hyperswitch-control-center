@module("papaparse")
external unparse: {"fields": array<string>, "data": array<array<string>>} => string = "unparse"
