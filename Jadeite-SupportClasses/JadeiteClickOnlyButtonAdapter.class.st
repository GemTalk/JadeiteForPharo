Class {
	#name : 'JadeiteClickOnlyButtonAdapter',
	#superclass : 'SpMorphicButtonAdapter',
	#category : 'Jadeite-SupportClasses',
	#package : 'Jadeite-SupportClasses'
}

{ #category : 'factory' }
JadeiteClickOnlyButtonAdapter >> buildWidget [

	| button |
	button := self newButton.
	button
		getEnabledSelector: #enabled;
		getFontSelector: #font;
		hResizing: #spaceFill;
		vResizing: #spaceFill;
		askBeforeChanging: self askBeforeChanging;
		setBalloonText: self getHelpText;
		dragEnabled: self dragEnabled;
		dropEnabled: self dropEnabled;
		eventHandler: (MorphicEventHandler new
				 on: #keyStroke
				 send: #keyStroke:fromMorph:
				 to: self).

	self color ifNotNil: [ self setWidgetColor: button ].
	"JfP change - don't bind space keystroke"

	^ button
]

{ #category : 'factory' }
JadeiteClickOnlyButtonAdapter >> newButton [

	^ JadeiteClickOnlyButtonMorph
		  on: self
		  getState: #state
		  action: #action
		  label: #label
		  menu: #menu:
]
