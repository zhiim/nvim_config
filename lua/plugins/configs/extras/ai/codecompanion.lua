return {
  'olimorris/codecompanion.nvim',
  cmd = { 'CodeCompanionActions', 'CodeCompanionChat', 'CodeCompanion' },
  dependencies = {
    'nvim-lua/plenary.nvim',
    'nvim-treesitter/nvim-treesitter',
    'ravitemer/codecompanion-history.nvim',
    'lalitmee/codecompanion-spinners.nvim',
  },
  keys = {
    {
      '<leader>cca',
      '<cmd>CodeCompanionActions<CR>',
      desc = 'CodeCompanion open action palette',
      mode = { 'n', 'v' },
    },
    {
      '<leader>cct',
      function()
        require('codecompanion').toggle {
          window_opts = { layout = 'vertical' },
        }
      end,
      desc = 'CodeCompanion chat toggle',
      mode = { 'n', 'v' },
    },
    {
      '<leader>ccf',
      function()
        require('codecompanion').toggle {
          window_opts = { layout = 'float', height = 0.8, width = 0.8 },
        }
      end,
      desc = 'CodeCompanion chat float',
      mode = { 'n', 'v' },
    },
    {
      '<leader>cci',
      function()
        require('codecompanion').toggle {
          window_opts = {
            layout = 'float',
            relative = 'cursor',
            width = 1,
            height = 0.4,
            row = 1,
          },
        }
      end,
      desc = 'CodeCompanion chat inline',
      mode = { 'n', 'v' },
    },
    {
      'q',
      function()
        if
          vim.api.nvim_get_option_value('filetype', { buf = 0 })
          == 'codecompanion'
        then
          vim.cmd 'CodeCompanionChat Toggle'
        end
      end,
      desc = 'Toggle the CodeCompanion Chat',
      mode = { 'n', 'v' },
    },
    {
      '<leader>ccs',
      ':CodeCompanionChat Add<CR>',
      desc = 'CodeCompanion add selected to Chat',
      mode = { 'n', 'v' },
    },
    {
      '<leader>ccp',
      '<cmd>CodeCompanion<CR>',
      desc = 'CodeCompanion insert prompt',
      mode = { 'n', 'v' },
    },
  },
  config = function()
    local change_model = function(chat)
      if chat.adapter.type == 'acp' then
        vim.notify(
          "Model can't be changed for ACP adapters",
          vim.log.levels.WARN
        )
        return
      end
      local function select_opts(prompt, conditional)
        return {
          prompt = prompt,
          kind = 'codecompanion.nvim',
          format_item = function(item)
            if conditional == item then
              return '* ' .. item
            end
            return '  ' .. item
          end,
        }
      end

      local config = require 'codecompanion.config'
      local util = require 'codecompanion.utils'
      if config.display.chat.show_settings then
        return util.notify(
          "Model can't be changed when `display.chat.show_settings = true`",
          vim.log.levels.WARN
        )
      end

      local current_model = vim.deepcopy(chat.adapter.schema.model.default)

      -- Select a model
      local models = chat.adapter.schema.model.choices
      if type(models) == 'function' then
        models = models(chat.adapter)
      end
      if not models or vim.tbl_count(models) < 2 then
        return
      end

      local new_model = chat.adapter.schema.model.default
      if type(new_model) == 'function' then
        new_model = new_model(chat.adapter)
      end

      models = vim
        .iter(models)
        :map(function(model, value)
          if type(model) == 'string' then
            return model
          else
            return value -- This is for the table entry case
          end
        end)
        :filter(function(model)
          return model ~= new_model
        end)
        :totable()
      table.insert(models, 1, new_model)

      vim.ui.select(
        models,
        select_opts('Select Model', new_model),
        function(selected)
          if not selected then
            return
          end

          if current_model ~= selected then
            util.fire('ChatModel', { bufnr = chat.bufnr, model = selected })
          end

          chat:apply_model(selected)
          chat:apply_settings()
        end
      )
    end

    local config = {
      opts = {
        language = "Chinese", -- The language used for LLM responses
      },
      display = {
        diff = {
          enabled = true,
          provider = "split",
          provider_opts = {
            split = {
              layout = "vertical",
              opts = {
                'internal',
                'filler',
                'closeoff',
                'algorithm:histogram',
                'indent-heuristic',
                'inline:word',
                'linematch:40',
              },
            },
          },
        },
        chat = {
          render_headers = false,
          window = {
            width = 0.33,
          },
        },
        action_palette = {
          provider = 'default',
        },
      },
      strategies = {
        chat = {
          adapter = 'gemini',
          roles = {
            llm = function(adapter)
              -- adapter.formatted_name is not save by history extension
              if
                adapter.parameters == nil or adapter.parameters.model == nil
              then
                return 'CodeCompanion (' .. adapter.formatted_name .. ')'
              end
              return 'CodeCompanion ('
                .. adapter.formatted_name
                .. ': '
                .. adapter.parameters.model
                .. ')'
            end,
          },
          keymaps = {
            send = { -- add process spinner
              modes = {
                n = { '<CR>', '<C-s>' },
                i = '<C-s>',
              },
              index = 2,
              callback = function(chat)
                vim.cmd 'stopinsert'
                chat:submit()
                chat:add_buf_message { role = 'llm', content = '' }
              end,
              description = 'Send message',
            },
            close = {
              modes = {
                n = '<C-x>',
                i = '<C-x>',
              },
              index = 3,
              callback = 'keymaps.close',
              description = 'Close Chat',
            },
            stop = {
              modes = {
                n = '<C-c>',
              },
              index = 4,
              callback = 'keymaps.stop',
              description = 'Stop Request',
            },
            change_model = {
              modes = {
                n = 'gm',
              },
              index = 15,
              callback = function(chat)
                change_model(chat)
              end,
              description = 'Change model',
            },
          },
        },
        inline = {
          adapter = 'gemini',
        },
      },
      adapters = {
        acp = {
          opts = {
            show_defaults = false, -- Show default adapters
          },
          gemini_cli = function()
            return require('codecompanion.adapters').extend('gemini_cli', {
              defaults = {
                auth_method = 'oauth-personal',
                oauth_credentials_path = vim.fs.abspath '~/.gemini/oauth_creds.json',
              },
              handlers = {
                -- do not auth again if oauth_credentials is already exists
                auth = function(self)
                  local oauth_credentials_path =
                    self.defaults.oauth_credentials_path
                  return (
                    oauth_credentials_path
                    and vim.fn.filereadable(oauth_credentials_path)
                  ) == 1
                end,
              },
            })
          end,
          qwen_code = function()
            return require('codecompanion.adapters').extend('gemini_cli', {
              name = 'qwen_code',
              formatted_name = 'Qwen Code',
              commands = {
                default = {
                  'qwen',
                  '--experimental-acp',
                },
                yolo = {
                  'qwen',
                  '--yolo',
                  '--experimental-acp',
                },
              },
              defaults = {
                auth_method = 'qwen-oauth',
                oauth_credentials_path = vim.fs.abspath '~/.qwen/oauth_creds.json',
              },
              handlers = {
                -- do not auth again if oauth_credentials is already exists
                auth = function(self)
                  local oauth_credentials_path =
                    self.defaults.oauth_credentials_path
                  return (
                    oauth_credentials_path
                    and vim.fn.filereadable(oauth_credentials_path)
                  ) == 1
                end,
              },
            })
          end,
        },
        http = {
          opts = {
            show_model_choices = false,
            proxy = vim.g.options.proxy,
            show_defaults = false, -- Show default adapters
          },
          copilot = 'copilot',
          gemini = function()
            return require('codecompanion.adapters').extend('gemini', {
              env = {
                api_key = vim.g.options.gemini_api_key,
              },
            })
          end,
        },
      },
      extensions = {
        history = {
          enabled = true, -- defaults to true
          opts = {
            keymap = 'gh',
            save_chat_keymap = 'gv',
            auto_save = false,
            picker = vim.g.options.picker == 'fzf_lua' and 'fzf-lua'
              or 'telescope',
            auto_generate_title = true,
            title_generation_opts = {
              adapter = 'gemini',
              model = 'gemini-2.5-flash-lite',
            },
          },
        },
        spinner = {
          enabled = true,
          opts = {
            style = 'snacks',
          },
        },
      },
      prompt_library = {
        ['English-Chinese-Translator'] = {
          strategy = 'chat',
          description = 'Translate bwtween English and Chinese',
          opts = {
            index = 12,
            modes = { 'n', 'v' },
            short_name = 'trans',
            user_prompt = false,
            is_slash_cmd = true,
          },
          prompts = {
            {
              role = 'system',
              content = [[# Role

You are a senior and professional translator with excellent Chinese-English translation skills, capable of completing various text translations accurately and fluently.

## Skills

### Skill 1: Chinese to English

1.  When a user provides Chinese text, quickly and highly accurately convert it into authentic English expressions.
2.  Strictly adhere to English grammar rules and idiomatic expressions to ensure the translation results are natural and fluent.
3.  Response example:
    \=====

*    English: <Translated English content>
    \=====

### Skill 2: English to Chinese

1.  When a user provides English text, accurately and clearly translate it into easy-to-understand Chinese.
2.  Focus on the naturalness and accuracy of Chinese expressions, ensuring the translation conforms to Chinese language habits.
3.  Response example:
    \=====

*    Chinese: <Translated Chinese content>
    \=====

## Restrictions:

*   Focus solely on translation between Chinese and English, without involving other languages.
*   Always ensure the accuracy and fluency of translations, and strictly follow the specified format for responses.]],
            },
            {
              role = 'user',
              content = [[]],
            },
          },
        },
        ['Grammar-Checker'] = {
          strategy = 'chat',
          description = 'Check English Grammer',
          opts = {
            index = 12,
            modes = { 'n', 'v' },
            short_name = 'grammar',
            user_prompt = false,
            is_slash_cmd = true,
          },
          prompts = {
            {
              role = 'system',
              content = [[The user will provide you with a body of English text and you will review the text to make sure it is written in correct grammar, is clear, and constructed in good English.

Follow these instructions:

- Make minimal changes, to the extent possible.
- ONLY return the revised text.
- After your response, indicate in bullet points how many changes there are and what they are inside square brackets. And if you have no changes, just say "Good to go, chief."
- You MUST mark ALL your changes (including revisions, additions, or deletions) bold in Markdown. Following examples demonstrate how you should mark your changes in your answer:
1. Make changed words or punctuations bold. Example: """ User: A taem of 60+ members Assistant: A **team** of 60+ members [Explanation: 1 change. The word "taem" was corrected as "team" and was marked bold.] """
2. Mark added words or punctuations bold. Example: """ User: A web server can enqueue a job but can it wait for worker process to complete Assistant: A web server can enqueue a job but can it wait for *a* worker process to complete **it?** [Explanation: 2 changes. The word "a" and word and punctuation "it?" was added and hence marked bold.] """
3. Mark the words that came before and after a deleted word or punctuation bold. Example: """ User: We've been noticing that some jobs get delayed by virtue of because of an issue with Redis. Assistant: We've been noticing that some jobs get delayed by virtue **of an** issue with Redis. [Explanation: 1 change. The words "because of" was deleted, therefore, the words before and after that part which were "of" and "an" were marked bold.] """
]],
            },
            {
              role = 'user',
              content = [[]],
            },
          },
        },
        ['Cpp-Expert'] = {
          strategy = 'chat',
          description = 'Cpp Expert',
          opts = {
            index = 12,
            modes = { 'n', 'v' },
            short_name = 'cpp',
            user_prompt = false,
            is_slash_cmd = true,
          },
          prompts = {
            {
              role = 'system',
              content = [[# Character

You're a patient and knowledgeable programming assistant who excels in teaching C++/Qt coding practices, debugging errors, and explaining complex concepts in a simple manner.

## Skills

### Skill 1: Teach C++/Qt Basics

- Provide clear explanations on basic C++/Qt syntax and functions.
- Use pertinent examples and exercises to make learning interactive.
- Correct mistakes and misconceptions with patience and clear explanations.

### Skill 2: Debug C++/Qt Code

- Analyze the user's code to identify and correct errors.
- Offer step-by-step solutions to fix issues.
- Explain why an error occurred and how to avoid it in future.

### Skill 3: Explain Advanced C++/Qt Concepts

- Break down complex concepts like decorators, generators, and context managers.
- Use analogies and real-world examples to make the explanations relatable.
- Provide example codes to illustrate difficult concepts.

## Constraints

- Stick to C++/Qt-related topics.
- Ensure explanations are concise yet comprehensive.
- Be patient and encouraging in all interactions.
]],
            },
            {
              role = 'user',
              content = [[]],
            },
          },
        },
        ['Python-Expert'] = {
          strategy = 'chat',
          description = 'Python Expert',
          opts = {
            index = 12,
            modes = { 'n', 'v' },
            short_name = 'python',
            user_prompt = false,
            is_slash_cmd = true,
          },
          prompts = {
            {
              role = 'system',
              content = [[You are an expert in Python development, including its core libraries, popular frameworks like Django, Flask, and FastAPI, data science libraries like NumPy and Pandas, and testing frameworks like pytest. You excel at choosing the best tools for each task, always striving to minimize unnecessary complexity and code duplication.

When providing suggestions, you break them down into discrete steps and recommend conducting small tests after each stage to ensure progress is on the right track.

When explaining concepts or when specifically requested, you provide code examples. However, if it is possible to answer without code, that is preferred. You are willing to elaborate when requested.

Before writing or suggesting code, you thoroughly review the existing codebase and describe its functionality between the \<CODE\_REVIEW> tags. After the review, you create a detailed plan for the proposed changes and include it within the <PLANNING> tags. You pay close attention to variable names and string literals, ensuring they remain consistent unless changes are necessary or requested. When naming according to conventions, you enclose it in double colons and use ::UPPERCASE::.

Your output strikes a balance between addressing the current issue and maintaining flexibility for future use.

If anything is unclear or ambiguous, you always seek clarification. When choices arise, you pause to discuss the trade-offs and implementation options.

Sticking to this approach is crucial, teaching your conversational partner to make effective decisions in Python development. You avoid unnecessary apologies and learn from previous interactions to prevent repeating mistakes.

You are highly attentive to security issues, ensuring that each step does not compromise data or introduce vulnerabilities. Whenever there are potential security risks (e.g., input handling, authentication management), you conduct additional reviews and present your reasoning between the \<SECURITY\_REVIEW> tags.

Finally, you consider the operational aspects of the solutions. You think about how to deploy, manage, monitor, and maintain Python applications. You highlight relevant operational issues at each step of the development process.
]],
            },
            {
              role = 'user',
              content = [[]],
            },
          },
        },
      },
    }

    local utils = require 'utils.util'
    local providers_path = vim.fn.stdpath 'config' .. '/providers.json'
    local custom_providers

    -- if not providers file, create one with example content
    if vim.fn.filereadable(providers_path) == 0 then
      local f = io.open(providers_path, 'w')
      if f then
        -- write example content
        f:write '{"none":{"name":"ExampleProvider","url":"https://ai.example.com","api_key":"","chat_url":"opt-/v1/chat/completions","models_endpoint":"opt-/v1/models","model":"opt"}}'
        f:close()
        custom_providers = {}
      else
        vim.notify(
          'cannot create providers.json',
          vim.log.levels.ERROR,
          { title = 'Cache Create' }
        )
        custom_providers = {}
      end
    else
      -- read providers file
      utils.with_file(
        providers_path,
        'r',
        function(file)
          -- read cache into options
          custom_providers = vim.json.decode(file:read '*a')
        end,
        function(err)
          vim.notify(
            'Error reading cache file: ' .. err,
            vim.log.levels.ERROR,
            { title = 'Cache Read' }
          )
        end
      )
    end

    -- loop through custom providers and add them to http adapters
    local http_adapters = {}
    for name, provider_info in pairs(custom_providers) do
      if
        name == 'nil' or
        -- must have name, url, api_key
        provider_info.name == nil
        or provider_info.url == nil
        or provider_info.api_key == nil
      then
        goto continue
      end

      -- basic provider options
      local provider_opts = {
        name = name,
        formatted_name = provider_info.name,
        env = {
          url = provider_info.url,
          api_key = provider_info.api_key,
        },
      }

      -- optional provider options
      if provider_info.chat_url ~= nil then
        provider_opts.env.chat_url = provider_info.chat_url
      end
      if provider_info.models_endpoint ~= nil then
        provider_opts.env.models_endpoint = provider_info.models_endpoint
      end
      if provider_info.model ~= nil then
        provider_opts.schema = {}
        provider_opts.schema.model = {}
        provider_opts.schema.model.default = provider_info.model
      end


      -- extend the openai_compatible adapter
      http_adapters[name] = function()
        return require('codecompanion.adapters').extend('openai_compatible', provider_opts)
      end
        ::continue::
    end

    -- add to codecompanion config
    for k, v in pairs(http_adapters) do
      config.adapters.http[k] = v
    end

    require('codecompanion').setup(config)
  end,
}
