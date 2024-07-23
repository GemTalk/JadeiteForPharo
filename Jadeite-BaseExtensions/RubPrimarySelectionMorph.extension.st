Extension { #name : 'RubPrimarySelectionMorph' }

{ #category : '*Jadeite-BaseExtensions' }
RubPrimarySelectionMorph >> whenTextAreaSelectionChanged: anAnnouncement [
	self owner ifNil: [ ^self ]. "Added by Jadeite - announcements to closed windows not handled well."
	firstIndex := self textArea markIndex min: self textArea pointIndex.
	lastIndex := self textArea pointIndex max: self textArea markIndex.
	self computeVertices.
	self announcer announce: RubTextSetInModel
]
