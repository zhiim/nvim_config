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
      local model_choices = chat.adapter.schema.model.choices
      local models = nil
      if type(model_choices) == 'function' then
        models = model_choices(chat.adapter, {async = false})
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

      local function get_model_id(model)
        return type(model) == "table" and model.id or model
      end

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

          local model_id = get_model_id(selected)
          chat:apply_model_or_command({ model = model_id })
          chat:apply_settings()
        end
      )
    end

    local config = {
      opts = {
        language = "the language I use", -- The language used for LLM responses
      },
      display = {
        diff = {
          enabled = true,
          provider = "inline",
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
          window = {
            width = 0.33,
          },
        },
        action_palette = {
          provider = 'default',
        },
      },
      interactions = {
        chat = {
          adapter = 'copilot',
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
          adapter = 'copilot',
        },
      },
      adapters = {
        acp = {
          opts = {
            show_presets = false, -- Show default adapters
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
            proxy = vim.g.options.proxy,
            cache_models_for = 10, -- cache models list for 10 minutes, almost no cache (for same adaptor, different API url)
            show_presets = false, -- do not show default adapters
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
            style = vim.g.options.mode == "IDE" and 'snacks' or "native" ,
          },
        },
      },
      prompt_library = {
        markdown = {
          dirs = {
            vim.fn.getcwd() .. "/.prompts",  -- project specific prompts
            vim.fn.stdpath("config") .. "/prompts"  -- built-in user prompts
          }
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
