"
I am a columns environment.
"
Class {
	#name : #PRColumnEnvironment,
	#superclass : #PRDocumentGroup,
	#category : #'Pillar-Model-Document'
}

{ #category : #testing }
PRColumnEnvironment class >> isAbstract [
	^ false
]

{ #category : #visiting }
PRColumnEnvironment >> accept: aVisitor [
	^ aVisitor visitColumns: self
]
