Class {
	#name : 'JadeiteTreeTableDataSource',
	#superclass : 'SpMorphicTreeTableDataSource',
	#traits : 'SpTMorphicTableDataSourceCommons',
	#classTraits : 'SpTMorphicTableDataSourceCommons classTrait',
	#category : 'Jadeite-SupportClasses',
	#package : 'Jadeite-SupportClasses'
}

{ #category : 'testing' }
JadeiteTreeTableDataSource >> shouldDisplayExpandableArrowFor: item [

	^item data hasSubclasses
]
