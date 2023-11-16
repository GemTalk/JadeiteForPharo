Class {
	#name : 'JadeiteTreeTableDataSource',
	#superclass : 'SpMorphicTreeTableDataSource',
	#traits : 'SpTMorphicTableDataSourceCommons',
	#classTraits : 'SpTMorphicTableDataSourceCommons classTrait',
	#category : 'Jadeite-ToolsSupportClasses'
}

{ #category : 'testing' }
JadeiteTreeTableDataSource >> shouldDisplayExpandableArrowFor: item [

	^item data hasSubclasses
]
