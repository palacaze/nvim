;; extends

; function/method docstring
(function_definition
  body: (block .
    (expression_statement
      (string
        (string_content) @injection.content (#set! injection.language "rst")
      )
    )
  )
)

; class docstring
(class_definition
  body: (block .
    (expression_statement
      (string
        (string_content) @injection.content (#set! injection.language "rst")
      )
    )
  )
)

; module docstring
(module .
  (expression_statement
    (string
      (string_content) @injection.content (#set! injection.language "rst")
    )
  )
)

;extends
(function_definition
  (block
    (expression_statement
      (string (string_content) @rst ) ) ) )

(assignment ((identifier) @_varx (#match? @_varx ".*js$")) (string (string_content) @javascript ) ) 
