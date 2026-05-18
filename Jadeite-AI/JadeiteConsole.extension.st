Extension { #name : 'JadeiteConsole' }

{ #category : '*Jadeite-AI' }
JadeiteConsole >> newToolsMenu [
	"Override trait method to prepend Ask Jadeite to the Tools submenu."

	^ self newMenu
		  addGroup: [ :group |
			  group addItem: [ :item |
				  item
					  name: 'Jadeite Agent';
					  icon: (self iconNamed: #glamorousHelp);
					  action: [ self openAIChatWindow ] ] ];
		  addGroup: [ :group |
			  group
				  addItem: [ :item |
					  item
						  name: self workspaceLabel;
						  icon: self workspaceIcon;
						  action: self workspaceAction ];
				  addItem: [ :item |
					  item
						  name: self browserLabel;
						  icon: self browserIcon;
						  action: self browserAction ];
				  addItem: [ :item |
					  item
						  name: self sunitBrowserLabel;
						  icon: self sunitBrowserIcon;
						  action: self sunitBrowserAction ] ];
		  addGroup: [ :group |
			  group
				  addItem: [ :item |
					  item
						  name: 'Process Browser';
						  icon: (self iconNamed: #processBrowser);
						  action: [ self openProcessBrowser ] ];
				  addItem: [ :item |
					  item
						  name: 'Windows Browser';
						  icon: (self iconNamed: #window);
						  action: [ self openWindowsBrowser ] ];
				  addItem: [ :item |
					  item
						  name: 'Jadeite Help';
						  action: [ self openJadeiteHelpWebPage ] ] ];
		  yourself
]

{ #category : '*Jadeite-AI' }
JadeiteConsole >> openAIChatWindow [
	"Open the AI chat window, passing the live GemStone session for source-context injection."

	JadeiteAIChatApplication showOnSession: self gciSession library
]
