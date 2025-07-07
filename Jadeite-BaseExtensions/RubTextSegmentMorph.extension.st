Extension { #name : 'RubTextSegmentMorph' }

{ #category : '*Jadeite-BaseExtensions' }
RubTextSegmentMorph >> computeStraightVertices [

	| firstCB lastCB firstLineIndex lastLineIndex firstLine lastLine verts lines textarea margins segmentGap textAreaLeft |
	self lines ifEmpty: [ ^ self ].
	firstCB := self characterBlockForIndex: firstIndex.
	lastCB := self characterBlockForIndex: lastIndex.
	lines := self lines ifNil: [^self].
	textarea := self textArea.
	margins := self margins.
	firstLineIndex := self lineIndexOfCharacterIndex: firstIndex.
	lastLineIndex := self lineIndexOfCharacterIndex: lastIndex.
	firstLine := lines at: firstLineIndex.
	lastLine := lines at: lastLineIndex.
	verts := OrderedCollection new.
	segmentGap := 1 @ 0.
	firstLine = lastLine
		ifTrue: [
			verts add: firstCB bottomLeft.
			verts add: firstCB topLeft.
			firstIndex ~= lastIndex ifTrue: [
				verts add: lastCB topLeft.
				verts add: lastCB bottomLeft.
				verts add: firstCB bottomLeft ] ]
		ifFalse: [
			textAreaLeft := textArea left + margins left.
			verts
				add: firstCB bottomLeft - segmentGap;
				add: firstCB topLeft - segmentGap.
			firstLineIndex to: lastLineIndex - 1 do: [ :index |
				| line |
				line := lines at: index.
				verts
					add: line actualWidth + margins left @ line top + segmentGap;
					add: line actualWidth + margins left @ line bottom + segmentGap ].

			verts
				add: lastCB topLeft + segmentGap;
				add: lastCB bottomLeft + segmentGap;
				add: textAreaLeft @ lastLine bottom - segmentGap;
				add: textAreaLeft @ firstLine bottom - segmentGap ].
	self setVertices: verts
]

{ #category : '*Jadeite-BaseExtensions' }
RubTextSegmentMorph >> lines [
	^ [self textArea paragraph lines] on: Error do:[:ex | ^nil]
]
