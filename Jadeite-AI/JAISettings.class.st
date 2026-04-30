"
JAISettings — resolves the Ollama adapter automatically when AI Chat is opened.

Ollama is free, runs entirely on your machine, and requires no account or API key.
If Ollama is not running, a setup dialog explains exactly what to do.
"
Class {
	#name : 'JAISettings',
	#superclass : 'Object',
	#category : 'Jadeite-AI',
	#package : 'Jadeite-AI'
}

{ #category : 'help' }
JAISettings class >> configurationHelpMessage [

	^ 'Jadeite AI Chat uses Ollama — a free LLM that runs entirely on your machine.
No account, no API key, and no data leaves your computer.

One-time setup:
  1. Download and install Ollama from:
       https://ollama.com
     (one installer, works on Mac, Windows, and Linux)

  2. Open a terminal and download a model:
       ollama pull qwen2.5-coder:7b
     (~5 GB download, only needed once — good at Smalltalk/GemStone code)

  3. Ollama starts automatically after install.
     If it is not running, start it with:
       ollama serve

Then select Console > AI Chat again — no restart needed.

For a lighter model on machines with less RAM:
  ollama pull llama3.2  (~2 GB)
  Then open a Workspace and evaluate:
    JAIOllamaAdapter forModel: ''llama3.2'''
]

{ #category : 'probing' }
JAISettings class >> isOllamaAvailable [
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
JAISettings class >> resolveAdapter [
	"Return a JAIOllamaAdapter if Ollama is running, otherwise nil.
	 Called fresh each time AI Chat is opened, so starting Ollama
	 and pressing the menu item again is all that is needed."

	self isOllamaAvailable ifTrue: [ ^ JAIOllamaAdapter default ].
	^ nil
]
