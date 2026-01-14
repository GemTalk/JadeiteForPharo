Extension { #name : 'ToolShortcutsCategory' }

{ #category : '*Jadeite-BaseExtensions' }
ToolShortcutsCategory >> openJadeiteLauncher [

	<shortcut>
	^ KMKeymap
		  shortcut: PharoShortcuts current openJadeiteLauncherShortcut
		  action: [ JadeiteConnectionApplication singleton start ]
]
