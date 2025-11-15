project('ollmchat-prompt', 'vala', 'c',
  version: '1.0.0',
  license: 'LGPL',
  default_options: [
    'default_library=static',
    'c_std=gnu11',
    'prefix=/usr'
  ]
)

gnome = import('gnome')

valac = meson.get_compiler('vala')

add_project_arguments(['--vapidir', meson.current_source_dir() / '../vapi'], language: 'vala')
add_project_arguments(['--target-glib=auto'], language: 'vala')

deps = [
  dependency('gtk4'),
  dependency('gee-0.8'),
  dependency('gio-2.0'),
  dependency('glib-2.0'),
  dependency('gobject-2.0'),
  dependency('json-glib-1.0'),
  dependency('libsoup-3.0'),
  valac.find_library('posix'),
]

# Compile resources for prompt system
ollmchat_resources = gnome.compile_resources(
  'ollmchat-resources',
  'resources/gresources.xml',
  source_dir: ['resources'],
  c_name: 'ollmchat_resources'
)

# Source files for Ollama namespace (needed by CodeAssistant)
ollmchat_ollama_src = files([
  'Ollama/Client.vala',
  'Ollama/Call/BaseCall.vala',
  'Ollama/Call/ChatCall.vala',
  'Ollama/Call/ModelsCall.vala',
  'Ollama/Call/PsCall.vala',
  'Ollama/Message.vala',
  'Ollama/MessageInterface.vala',
  'Ollama/OllamaBase.vala',
  'Ollama/Response/BaseResponse.vala',
  'Ollama/Response/ChatResponse.vala',
  'Ollama/Response/Model.vala',
  'Ollama/Tool/Tool.vala',
  'Ollama/Tool/Function.vala',
])

# Source files for prompt system
ollmchat_prompt_src = files([
  'Prompt/BaseAgentPrompt.vala',
  'Prompt/CodeAssistant.vala',
])

# Build as a library (can be linked or used as standalone)
ollmchat_prompt_lib = library('ollmchat-prompt',
  dependencies: deps,
  sources: [ollmchat_ollama_src, ollmchat_prompt_src, ollmchat_resources],
  install: false
)

# Build as executable for testing (optional)
ollmchat_prompt_test = executable('ollmchat-prompt-test',
  dependencies: deps,
  sources: [ollmchat_ollama_src, ollmchat_prompt_src, ollmchat_resources],
  install: false
)

