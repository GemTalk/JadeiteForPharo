Class {
	#name : 'JadeiteForPharoWorkspaceTestCase',
	#superclass : 'JadeiteForPharoGUITestCase',
	#category : 'Jadeite-Tests',
	#package : 'Jadeite-Tests'
}

{ #category : 'tests' }
JadeiteForPharoWorkspaceTestCase >> test_workspaceAdHocDisplayUnicodeCharacters [
	self testsIssue: #issue678
		withTitle: 'Print-it for out of range characters is... peculiar (3.0.92.3)'.
	workspace := (JadeiteWorkspace showOnSession: session)
				caption: 'Jade Workspace - Test Unicode Characters'.
	workspace codePane documentPresenter
		value: '''aa'', (String with: (Character withValue: 353)), ''bb''  '.
	workspace codePane selectAll.
	self displayAndPrint.
	self assert: workspace codePane documentPresenter selection equals: ' "''aašbb''"'.
	self assert: workspace codePane text
		equals: '''aa'', (String with: (Character withValue: 353)), ''bb''   "''aašbb''"'
]
