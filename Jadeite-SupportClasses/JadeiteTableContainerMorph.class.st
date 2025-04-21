Class {
	#name : 'JadeiteTableContainerMorph',
	#superclass : 'FTTableContainerMorph',
	#category : 'Jadeite-SupportClasses',
	#package : 'Jadeite-SupportClasses'
}

{ #category : 'drawing' }
JadeiteTableContainerMorph >> addResizeSplitters [
	"Jadeite - use a different column resizer morph"

	| columnWidths nextColumn delta |
	columnWidths := self calculateColumnWidths.
	nextColumn := self left.
	delta := self defaultColumnResizerMorph resizerWidth / 2.
	self table columns overlappingPairsWithIndexDo: [
		:leftColumn
		:rightColumn
		:index |
		nextColumn := nextColumn + (columnWidths at: index)
		              + self table intercellSpacing x.
		self addMorph: ((self defaultColumnResizerMorph
				  container: self
				  left:
					  (FTDisplayColumn
						   column: leftColumn
						   width: (columnWidths at: index))
				  right: (FTDisplayColumn
						   column: rightColumn
						   width: (columnWidths at: index + 1)))
				 bounds:
					 (nextColumn - delta @ self top extent: delta @ self height);
				 color: Color transparent;
				 yourself) ]
]

{ #category : 'private' }
JadeiteTableContainerMorph >> createResizableHeaderWith: aMorph between: leftColumn and: rightColumn [
	"Create a wrapper morph with a resizable morph et the left (so we bind two columns).
	 This morph will be completely transparent in all terms... it acts just as a container."

	^ Morph new
		  color: Color transparent;
		  clipSubmorphs: true;
		  layoutPolicy: FTRowLayout new;
		  bounds: aMorph bounds;
		  addMorphBack: (self defaultColumnResizerMorph
				   container: self
				   left: leftColumn
				   right: rightColumn);
		  addMorphBack: aMorph;
		  yourself
]

{ #category : 'drawing' }
JadeiteTableContainerMorph >> defaultColumnResizerMorph [

	^ JadeiteColumnResizerMorph
]
