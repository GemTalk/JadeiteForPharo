"
Most Jadeite tests assume a login is already present. 
This tests aspects of login without that assumption.
"
Class {
	#name : 'JadeiteLoginTestCase',
	#superclass : 'TestCase',
	#instVars : [
		'session',
		'jadeiteLogin',
		'parmFileName',
		'jadeiteShell'
	],
	#category : 'JadeiteTests'
}
