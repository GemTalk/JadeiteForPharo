Class {
	#name : 'JadeiteColumnResizerMorph',
	#superclass : 'FTColumnResizerMorph',
	#category : 'Jadeite-SupportClasses',
	#package : 'Jadeite-SupportClasses'
}

{ #category : 'event handling' }
JadeiteColumnResizerMorph >> doubleClick: evt [

	| maxWidth projectServices console aspectIndex aspect header |
	console := container table dataSource model owner. "yuck"
	(console isKindOf: JadeiteConsole) ifFalse: [ ^ self ].
	projectServices := console projectListPresenter items.
	aspectIndex := console projectColumns indexOf:
		               leftColumn column model.
	aspect := console projectDisplayAttributes keys at: aspectIndex.
	header := console projectDisplayAttributes values at: aspectIndex.
	maxWidth := projectServices inject: 0 into: [ :max :projectService |
		            | maxAspect maxHeader |
		            maxAspect := self theme textFont widthOfStringOrText:
			                         (projectService perform: aspect).
		            maxHeader := self theme textFont widthOfStringOrText:
			                         header.
		            (max max: maxAspect) max: maxHeader ].
	leftColumn column model width: maxWidth + 5
]

{ #category : 'event handling' }
JadeiteColumnResizerMorph >> mouseDown: anEvent [
	"A mouse button has been pressed.
	Update the color for feedback and store the mouse
	position and relative offset to the receiver.
	
	Jadeite - setup the doubleClickSelector."

	| cp |
	self canResizeColumn ifFalse: [ ^ self ].
	(self bounds containsPoint: anEvent cursorPoint) ifTrue: [
		oldColor := self color.
		self setGrabbedColor ].
	cp := anEvent cursorPoint.
	lastMouse := {
		             cp.
		             (cp - self position) }.

	(anEvent hand mouseClickStateFor: self event: anEvent)
		doubleClickSelector: #doubleClick:
]
