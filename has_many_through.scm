
(call
  method: (identifier) @method (#eq? @method "has_many")
  arguments: (argument_list
    (simple_symbol) @association) @args
  (#match? @args "through:"))