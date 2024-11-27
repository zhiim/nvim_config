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
        local items = { 'gemini_flash', 'gemini_pro', 'gemini_1', 'copilot_claude', 'copilot_4o', 'copilot_o1' }
        vim.ui.select(items, {
          prompt = 'Select a model:',
          format_item = function(item)
            return item
          end,
        }, function(selected)
          if require('utils.util').find_value(selected, items) then
            vim.cmd('CodeCompanionChat ' .. selected)
          else
            return
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
          adapter = 'gemini_pro',
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
          adapter = 'gemini_pro',
        },
      },
      adapters = {
        gemini_flash = function()
          return require('codecompanion.adapters').extend('gemini', {
            env = {
              api_key = vim.g.options.gemini_api_key,
            },
            schema = {
              model = {
                default = 'gemini-1.5-flash',
              },
            },
          })
        end,
        gemini_pro = function()
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
        gemini_1 = function()
          return require('codecompanion.adapters').extend('gemini', {
            env = {
              api_key = vim.g.options.gemini_api_key,
            },
            schema = {
              model = {
                default = 'gemini-1.0-pro',
              },
            },
          })
        end,
        copilot_claude = function()
          return require('codecompanion.adapters').extend('copilot', {
            schema = {
              model = {
                default = 'claude-3.5-sonnet',
              },
            },
          })
        end,
        copilot_4o = function()
          return require('codecompanion.adapters').extend('copilot', {
            schema = {
              model = {
                default = 'gpt-4o-2024-08-06',
              },
            },
          })
        end,
        copilot_o1 = function()
          return require('codecompanion.adapters').extend('copilot', {
            schema = {
              model = {
                default = 'o1-preview-2024-09-12',
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
        ['English-Chinese-Translator'] = {
          strategy = 'chat',
          description = 'Translate bwtween English and Chinese',
          opts = {
            adapter = {
              name = 'gemini_pro',
            },
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
  **English**: <Translated English content>

### Skill 2: English to Chinese

1.  When a user provides English text, accurately and clearly translate it into easy-to-understand Chinese.
2.  Focus on the naturalness and accuracy of Chinese expressions, ensuring the translation conforms to Chinese language habits.
3.  Response example:
  **Chinese**: <Translated Chinese content>

## Restrictions:

*   Focus solely on translation between Chinese and English, without involving other languages.
*   Always ensure the accuracy and fluency of translations, and strictly follow the specified format for responses.
]],
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
            adapter = {
              name = 'gemini_pro',
            },
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
        ['Machine-Learning-PRO'] = {
          strategy = 'chat',
          description = 'Machine Learning Expert',
          opts = {
            adapter = {
              name = 'gemini_pro',
            },
            modes = { 'n', 'v' },
            short_name = 'mlpro',
            user_prompt = false,
            is_slash_cmd = true,
          },
          prompts = {
            {
              role = 'system',
              content = [[# Character

You are a knowledgeable and patient AI assistant specializing in machine learning and deep learning. Your expertise covers theoretical concepts as well as practical implementation using PyTorch. You're here to help users understand complex ML/DL ideas and assist with PyTorch programming.

## Skills

### Skill 1: ML/DL Concept Explanation

- Explain machine learning and deep learning concepts clearly and concisely.
- Break down complex ideas into easily understandable parts.
- Provide relevant examples to illustrate theoretical concepts.

### Skill 2: PyTorch Programming Assistance

- Help users write PyTorch code for various ML/DL tasks.
- Debug and optimize PyTorch implementations.
- Suggest best practices for efficient PyTorch programming.

### Skill 3: ML/DL Model Architecture Design

- Guide users in designing appropriate neural network architectures.
- Explain the rationale behind different model components and layers.
- Assist in choosing suitable models for specific ML/DL problems.

### Skill 4: ML/DL Research Paper Interpretation

- Help users understand key ideas from recent ML/DL research papers.
- Explain novel algorithms and techniques presented in academic literature.
- Assist in implementing paper concepts using PyTorch.

## Constraints:

- Focus solely on machine learning, deep learning, and PyTorch-related topics.
- Maintain a patient and encouraging tone, especially for beginners.
- Provide step-by-step explanations when necessary.
- Use analogies and visualizations to aid understanding when appropriate.
- Encourage best practices in ML/DL.
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
            adapter = {
              name = 'gemini_pro',
            },
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
            adapter = {
              name = 'gemini_pro',
            },
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
  end,
}
