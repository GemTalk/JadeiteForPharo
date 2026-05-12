"
JadeiteAISettings — resolves an LLM adapter when AI Chat is opened.

Preference order:
  1. Claude (Anthropic API) — if ANTHROPIC_API_KEY is set in the environment
  2. Ollama — if running on localhost:11434

If neither is available a setup dialog explains what to do.
"
Class {
	#name : 'JadeiteAISettings',
	#superclass : 'Object',
	#category : 'Jadeite-AI',
	#package : 'Jadeite-AI'
}

{ #category : 'help' }
JadeiteAISettings class >> configurationHelpMessage [

	^ 'Jadeite AI Chat requires one of the following:

Option 1 — Claude (Anthropic API, recommended):
  Set the ANTHROPIC_API_KEY environment variable before starting Pharo:
    export ANTHROPIC_API_KEY=''sk-ant-...''
  Get a key at https://console.anthropic.com

Option 2 — Ollama (free, runs locally, no account needed):
  1. Download and install Ollama from https://ollama.com
  2. Pull a model:
       ollama pull qwen2.5-coder:7b
  3. If Ollama is not running:
       ollama serve

Then select Console > AI Chat again — no restart needed.'
]

{ #category : 'probing' }
JadeiteAISettings class >> isOllamaAvailable [
	"Return true if Ollama is listening on localhost:11434.
	 Short timeout so the probe fails fast when Ollama is not running."

	[ ZnClient new
		beOneShot;
		url: 'http://localhost:11434';
		timeout: 2;
		get.
	^ true ]
		on: Error
		do: [ ^ false ]
]

{ #category : 'resolution' }
JadeiteAISettings class >> resolveAdapter [
	"Return the best available adapter.
	 Uses Claude if a key is already cached or set in the environment.
	 Otherwise uses Ollama if running.
	 Only prompts for a Claude key if Ollama is also unavailable."

	| claude |
	claude := JadeiteAIClaudeAdapter default.
	claude isAvailable ifTrue: [ ^ claude ].
	self isOllamaAvailable ifTrue: [ ^ JadeiteAIOllamaAdapter default ].
	JadeiteAIClaudeAdapter requestApiKey ifNotNil: [ ^ JadeiteAIClaudeAdapter default ].
	^ nil
]
