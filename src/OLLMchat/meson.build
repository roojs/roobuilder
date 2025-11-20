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

# Dependencies for test-window (includes GTK UI)
test_window_deps = [
  dependency('gtk4'),
  dependency('gtksourceview-5'),
  dependency('gee-0.8'),
  dependency('gio-2.0'),
  dependency('glib-2.0'),
  dependency('gobject-2.0'),
  dependency('json-glib-1.0'),
  dependency('libsoup-3.0'),
  valac.find_library('posix'),
]

# Dependencies for test-ollama (command-line only)
test_ollama_deps = [
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
  source_dir: ['resources/ollmchat-agents'],
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
  'Ollama/Response/CallFunction.vala',
  'Ollama/Response/ChatResponse.vala',
  'Ollama/Response/Model.vala',
  'Ollama/Response/ToolCall.vala',
  'Ollama/Tool/Tool.vala',
  'Ollama/Tool/Param.vala',
  'Ollama/Tool/ParamSimple.vala',
  'Ollama/Tool/ParamObject.vala',
  'Ollama/Tool/ParamArray.vala',
  'Ollama/Tool/Function.vala',
])

# Source files for prompt system
ollmchat_prompt_src = files([
  'Prompt/BaseAgentPrompt.vala',
  'Prompt/CodeAssistantProviderInterface.vala',
  'Prompt/CodeAssistantProviderDummy.vala',
  'Prompt/CodeAssistant.vala',
])

# Source files for Tools namespace
ollmchat_tools_src = files([
  'Tools/PermissionProvider.vala',
  'Tools/PermissionProviderDummy.vala',
  'Tools/ReadFileTool.vala',
])

# Build as a library (can be linked or used as standalone)
ollmchat_prompt_lib = library('ollmchat-prompt',
  dependencies: deps,
  sources: [ollmchat_ollama_src, ollmchat_prompt_src, ollmchat_tools_src, ollmchat_resources],
  install: false
)

# UI source files (for test-window)
ollmchat_ui_src = files([
  'UI/ChatWidget.vala',
  'UI/ChatView.vala',
  'UI/ChatInput.vala',
  'MarkdownProcessor.vala',
])

# Build test-ollama executable (command-line test)
test_ollama = executable('test-ollama',
  dependencies: test_ollama_deps,
  sources: [
    'TestOllama.vala',
    ollmchat_ollama_src,
    ollmchat_prompt_src,
    ollmchat_tools_src,
    ollmchat_resources,
  ],
  install: false
)

# Build test-window executable (GTK UI test)
test_window = executable('test-window',
  dependencies: test_window_deps,
  sources: [
    'TestWindow.vala',
    ollmchat_ollama_src,
    ollmchat_prompt_src,
    ollmchat_tools_src,
    ollmchat_ui_src,
    ollmchat_resources,
  ],
  install: false
)

