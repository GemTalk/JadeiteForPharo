Extension { #name : 'ToolShortcutsCategory' }

{ #category : '*Jadeite-BaseExtensions' }
ToolShortcutsCategory >> openJadeiteConsole [

	<shortcut>
	^ KMKeymap
		  shortcut: PharoShortcuts current openJadeiteConsoleShortcut
		  action: [
				  JadeiteConsole currentConsole ifNotNil: [ :console |
					  console adapter widget window restoreAndActivate ] ]
]

{ #category : '*Jadeite-BaseExtensions' }
ToolShortcutsCategory >> openJadeiteLauncher [

	<shortcut>
	^ KMKeymap
		  shortcut: PharoShortcuts current openJadeiteLauncherShortcut
		  action: [ JadeiteConnectionApplication singleton start ]
]
