"
Only Mouse Clicks accepted on this button
No defaults of space and command return
"
Class {
	#name : 'JadeiteClickOnlyButtonMorph',
	#superclass : 'SpPluggableButtonMorph',
	#category : 'Jadeite-SupportClasses',
	#package : 'Jadeite-SupportClasses'
}

{ #category : 'shortcuts' }
JadeiteClickOnlyButtonMorph class >> buildPluggableButtonShortcutsOn: aBuilder [

	<keymap>
	(aBuilder shortcut: #action)
		category: #JadeiteClickOnlyButtonMorph
		default:
		Character space asKeyCombination | Character cr asKeyCombination
		do: [ :target :morph :event |
			event isKeyboard ifFalse: [ morph performAction: event ] ]
]

{ #category : 'keyboard' }
JadeiteClickOnlyButtonMorph >> keyDown: event [
	"mouse clicks only"

	
]

{ #category : 'keyboard' }
JadeiteClickOnlyButtonMorph >> keyStroke: event [
	"mouse clicks only"
]

{ #category : 'accessing' }
JadeiteClickOnlyButtonMorph >> performAction [

	"we ignore the actions from PluggableToggleButtonMorph
	and rely on our own actions that come through performAction:
	This way we can filter out keyboard events"
]

{ #category : 'accessing' }
JadeiteClickOnlyButtonMorph >> performAction: event [

	event isKeyboard ifFalse: [ ^ super performAction: event ]
]
