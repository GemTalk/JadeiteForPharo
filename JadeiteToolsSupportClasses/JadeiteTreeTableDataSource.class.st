Class {
	#name : 'JadeiteTreeTableDataSource',
	#superclass : 'SpMorphicTreeTableDataSource',
	#traits : 'SpTMorphicTableDataSourceCommons',
	#classTraits : 'SpTMorphicTableDataSourceCommons classTrait',
	#category : 'JadeiteToolsSupportClasses'
}

{ #category : 'testing' }
JadeiteTreeTableDataSource >> shouldDisplayExpandableArrowFor: item [

	^item data hasSubclasses
]
