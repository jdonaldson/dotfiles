local ollama = require("model.providers.ollama")

local function input_if_selection(input, context)
  return context.selection and input or ''
end

M = {
  ['ollama:phi'] = {
    provider = ollama,
    params = {
      model = 'phi',
    },
    create = input_if_selection,
    run = function(messages, config)
      if config.system then
        table.insert(messages, 1, {
          role = 'system',
          content = config.system,
        })
      end

      return { messages = messages }
    end,
  },
}
return M
