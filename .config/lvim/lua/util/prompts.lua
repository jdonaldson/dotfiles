local openai = require("model.providers.openai")
local ollama = require("model.providers.ollama")
local mode = require('model').mode
local extract = require('model.prompts.extract')
local util = require('util')


M = {
  gpt4 = {
    provider = openai,
    mode = mode.INSERT_OR_REPLACE,
    params = {
      temperature = 0.2,
      max_tokens = 1000,
      model = 'gpt-4',
    },
    builder = function(input, context)
      return openai.adapt(util.code_replace_fewshot(input, context))
    end,
    transform = extract.markdown_code,
  },
  code = {
    provider = ollama,
    mode = mode.INSERT_OR_REPLACE,
    params = {
      model = 'codellama',
    },
  },
}

return M

