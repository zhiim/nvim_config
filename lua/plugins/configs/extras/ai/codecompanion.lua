return {
  'olimorris/codecompanion.nvim',
  cmd = { 'CodeCompanionActions', 'CodeCompanionChat', 'CodeCompanion' },
  keys = {
    {
      '<leader>cca',
      '<cmd>CodeCompanionActions<CR>',
      desc = 'Open the CodeCompanion Action Palette',
      mode = { 'n', 'v' },
    },
    {
      '<leader>ccc',
      '<cmd>CodeCompanionChat Toggle<CR>',
      desc = 'Toggle the CodeCompanion Chat',
      mode = { 'n', 'v' },
    },
    {
      'q',
      function()
        if vim.api.nvim_get_option_value('filetype', { buf = 0 }) == 'codecompanion' then
          vim.cmd 'CodeCompanionChat Toggle'
        end
      end,
      desc = 'Toggle the CodeCompanion Chat',
      mode = { 'n', 'v' },
    },
    {
      '<leader>ccs',
      ':CodeCompanionChat Add<CR>',
      desc = 'Add Selected to CodeCompanion Chat',
      mode = { 'n', 'v' },
    },
    {
      '<leader>ccp',
      '<cmd>CodeCompanion<CR>',
      desc = 'CodeCompanion',
      mode = { 'n', 'v' },
    },
    {
      '<leader>ccm',
      function()
        vim.ui.input({ prompt = 'Select a model: ' }, function(input)
          if input then
            vim.cmd('CodeCompanionChat ' .. input)
          end
        end)
      end,
      desc = 'CodeCompanionChat with a Selected Model',
      mode = { 'n', 'v' },
    },
  },
  config = function()
    require('codecompanion').setup {
      display = {
        chat = {
          render_headers = false,
          show_settings = true,
          window = {
            width = 0.3,
          },
        },
      },
      strategies = {
        chat = {
          adapter = 'gemini',
          keymaps = {
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
          },
        },
        inline = {
          adapter = 'gemini',
        },
      },
      adapters = {
        gemini = function()
          return require('codecompanion.adapters').extend('gemini', {
            env = {
              api_key = vim.g.options.gemini_api_key,
            },
            schema = {
              model = {
                default = 'gemini-1.5-pro',
              },
            },
          })
        end,
        copilot = function()
          return require('codecompanion.adapters').extend('copilot', {
            schema = {
              model = {
                default = 'claude-3.5-sonnet',
              },
            },
          })
        end,
        opts = {
          language = 'Chinese',
          proxy = vim.g.options.proxy,
        },
      },
      prompt_library = {
        ['Translator'] = {
          strategy = 'chat',
          description = 'Translate bwtween English and Chinese',
          opts = {
            adapter = {
              name = 'gemini',
            },
            modes = { 'n', 'v' },
            short_name = 'trans',
            user_prompt = false,
            is_slash_cmd = true,
          },
          prompts = {
            {
              role = 'system',
              content = [[- Expertise: 双向翻译
- Language Pairs: 中文 <-> 英文
- Description: 你是一个中英文翻译专家，将用户输入的中文翻译成英文，或将用户输入的英文翻译成中文。对于英文内容，你要提供中文翻译结果；对于中文内容，你要提供英文翻译结果。我会向你发送需要翻译的内容，你要回答相应的翻译结果，并确保符合中文或英文语言习惯，你可以调整语气和风格，并考虑到某些词语的文化内涵和地区差异。同时作为翻译家，需将原文翻译成具有信达雅标准的译文。"信" 即忠实于原文的内容与意图；"达" 意味着译文应通顺易懂，表达清晰；"雅" 则追求译文的文化审美和语言的优美。目标是创作出既忠于原作精神，又符合目标语言文化和读者审美的翻译。
]],
            },
            {
              role = 'user',
              content = [[如果下面的内容是中文，翻译成英文；如果是英文，则翻译成中文。只返回翻译的结果，不要其他信息：
]],
            },
          },
        },
      },
    }
  end,
}
