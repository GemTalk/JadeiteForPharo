Class {
	#name : 'ScintillaView',
	#superclass : 'DolphinClass',
	#category : 'Jadeite-ToolsSupportClasses'
}

{ #category : 'menus' }
ScintillaView >> trackContextMenu: aPointEvent [
	"Private - Shows and tracks a context menu for the receiver from the mouse position in
	aPointEvent. Answer nil if the receiver does not have a contextMenu to show, or a Boolean if
	it has."

	^self queryContextMenu 
		ifNotNil: 
			[:menu | 
			| pos |
			pos := aPointEvent position.
			pos = (-1 @ -1) ifTrue: [pos := self positionForKeyboardContextMenu].
			ShortcutMenuStatus start.
			menu showIn: self position: pos.
			ShortcutMenuStatus stop.
			true]
]
