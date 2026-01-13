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
			event isKeyboard ifFalse: [ morph performAction ] ]
]

{ #category : 'keyboard' }
JadeiteClickOnlyButtonMorph >> keyDown: event [
	"mouse clicks only"

	
]

{ #category : 'keyboard' }
JadeiteClickOnlyButtonMorph >> keyStroke: event [
	"mouse clicks only"
]
