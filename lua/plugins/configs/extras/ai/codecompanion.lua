local ai_opts = vim.g.options.plugins.ai

return {
  'olimorris/codecompanion.nvim',
  enabled =  ai_opts.components.codecomponion
    or ai_opts.enable_all,
  cmd = { 'CodeCompanionActions', 'CodeCompanionChat', 'CodeCompanion', 'CodeCompanionCLI' },
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
      '<leader>ccc',
      '<cmd>CodeCompanionCLI<CR>',
      desc = 'CodeCompanion CLI',
      mode = { 'n', 'v' },
    },
    {
      'q',
      function()
        if
          vim.api.nvim_get_option_value('filetype', { buf = 0 })
          == 'codecompanion'
        then
          require('codecompanion').toggle()
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
      function ()
        require("codecompanion").cli({ prompt = true })
      end,
      desc = 'CodeCompanion prompt',
      mode = { 'n', 'v' },
    },
  },
  config = function()
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
          show_settings = false,  -- cannot change adapter when `show_settings` is enabled
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
          adapter = 'gateway',
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
                .. " ["
                .. adapter.parameters.reasoning_effort
                .. "]"
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
                n = 'gp',
              },
              index = 4,
              callback = 'keymaps.stop',
              description = 'Stop Request',
            },
            change_model = {
              modes = {
                n = 'go',
              },
              index = 15,
              callback = function(chat)
                require("codecompanion.interactions.chat.keymaps.change_adapter").select_model(chat)
              end,
              description = 'Change model',
            },
            change_thinking_level = {
              modes = {
                n = 'gt',
              },
              index = 16,
              callback = function(chat)
                local available_levels = { "minimal", "low", "medium", "high", "max" }
                local settings = chat.settings
                vim.ui.select(available_levels, {
                  prompt = "Select thinking level:",
                }, function(choice)
                  if choice then
                    settings.reasoning_effort = choice
                    vim.notify("Thinking level set to: " .. choice)
                  else
                    vim.notify("No thinking level selected")
                  end
                end)
                chat:apply_settings(settings)
              end,
              description = 'Change thinking level',
            }
          },
        },
        inline = {
          adapter = 'gateway',
        },
        cli = {
          agent = "pi_agent",
          agents = {
            pi_agent = {
              cmd = "pi",
              args = {},
              description = "Pi Code Agent",
              provider = "terminal",
            }
          }
        }
      },
      adapters = {
        acp = {
          opts = {
            show_presets = false, -- Show default adapters
          },
          pi_agent = function()
            local helpers = require("codecompanion.adapters.acp.helpers")
            return {
              name = "pi_agent",
              formatted_name = "PI Agent",
              type = "acp",
              roles = {
                llm = "assistant",
                user = "user",
              },
              opts = {
                vision = false,
              },
              commands = {
                default = {
                  "pi-acp"
                },
              },
              defaults = {
                mcpServers = {},
                timeout = 120000,
              },
              env = {
              },
              parameters = {
                protocolVersion = 1,
                clientCapabilities = {
                  fs = { readTextFile = true, writeTextFile = true },
                },
                clientInfo = {
                  name = "CodeCompanion.nvim",
                  version = "1.0.0",
                },
              },
              handlers = {
                setup = function(self)
                  return true
                end,
                auth = function(self)
                  return true
                end,
                form_messages = function(self, messages, capabilities)
                  return helpers.form_messages(self, messages, capabilities)
                end,
                on_exit = function(self, code) end,
              },
            }
          end
        },
        http = {
          opts = {
            proxy = vim.g.options.settings.proxy,
            cache_models_for = 1800, -- cache models list for certain seconds
            show_presets = false, -- do not show default adapters
          },
          gateway = function()
            return require('codecompanion.adapters').extend('openai_compatible', {
              name = "gateway",
              formatted_name = "Gateway",
              env = {
                url = "PROVIDER_BASE_URL",
                api_key = "PROVIDER_API_KEY",
              },
              handlers = {
                parse_message_meta = function (self, data)  -- display reasoning content in chat if available
                  local reasoning_content = data.extra and data.extra.reasoning or data.extra.reasoning_content
                  if reasoning_content then
                    data.output.reasoning = { content = reasoning_content }
                    if data.output.content == "" then
                      data.output.content = nil
                    end
                  end
                  return data
                end
              },
              schema = {
                reasoning_effort = {
                  mapping = "parameters",
                  type = "string",
                  optional = true,
                  default = "medium",
                  choices = { "minimal", "low", "medium", "high", "max" },
                },
              }
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
            picker = vim.g.options.picker.chosen == 1 and 'fzf-lua'
              or 'telescope',
            auto_generate_title = false,
          },
        },
        spinner = {
          enabled = true,
          opts = {
            style = (vim.g.options.mode.chosen == 2 and ( vim.g.options.plugins.util.enable_all or vim.g.options.plugins.util.components.snacks )) and 'snacks' or "native" ,
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
        name == 'none' or
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
