Extension { #name : 'FTColumnResizerMorph' }

{ #category : '*Jadeite-BaseExtensions' }
FTColumnResizerMorph >> doubleClick: evt [

	| maxWidth projectServices console aspectIndex aspect header |
	console := container table dataSource model owner. "yuck"
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

{ #category : '*Jadeite-BaseExtensions' }
FTColumnResizerMorph >> mouseDown: anEvent [
	"A mouse button has been pressed.
	Update the color for feedback and store the mouse
	position and relative offset to the receiver.
	
	Jadeite exention - setup the doubleClickSelector."

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
