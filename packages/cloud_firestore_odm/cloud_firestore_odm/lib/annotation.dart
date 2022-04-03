export 'src/validator.dart' show Min, Validator, Max;

/// Defines a collection reference.
///
/// To define a collection reference, first it is necessary to define a class
/// representing the content of a document of the collection.
///
/// That can be done by defining any serializable Dart class, such as by using
/// [json_serializable](https://pub.dev/packages/json_serializable) as followed:
///
/// ```dart
/// @JsonSerializable()
/// class Person {
///   Person({required this.name, required this.age});
///
///   factory Person.fromJson(Map<String, Object?> json) => _$PersonFromJson(json);
///
///   final String name;
///   final String age;
///
///   Map<String, Object?> toJson() => _$PersonToJson(this);
/// }
/// ```
///
///
/// Then, we should define a global variable representing our collection reference,
/// using the `Collection` annotation.
///
/// To do so, we must specify the path to the collection and the type of the collection
/// content:
///
/// ```dart
/// @Collection<Person>('persons')
/// final personsRef = PersonCollectionReference();
/// ```
///
/// The class `PersonCollectionReference` will be generated from the `Person` class,
/// and will allow manipulating the collection in a type-safe way. For example, to
/// read the person collection, you could do:
///
/// ```dart
/// void main() async {
///   PersonQuerySnapshot snapshot = await personsRef.get();
///
///   for (PersonQueryDocumentSnapshot doc in snapshot.docs) {
///     Person person = doc.data();
///     print(person.name);
///   }
/// }
/// ```
///
/// **Note**
/// Don't forget to include `part "my_file.g.dart"` at the top of your file.
///
///
/// ### Obtaining a document reference.
///
///
/// It is possible to obtain a document reference from a collection reference.
///
/// Assuming we have:
///
/// ```dart
/// @Collection<Person>('persons')
/// final personsRef = PersonCollectionReference();
/// ```
///
/// then we can get a document with:
///
/// ```dart
/// void main() async {
///   PersonDocumentReference doc = personsRef.doc('document-id');
///
///   PersonDocumentSnapshot snapshot = await doc.get();
/// }
/// ```
///
/// ### Defining a sub-collection
///
/// Once you have defined a collection, you may want to define a sub-collection.
///
/// To do that, you first must create a root collection as described previously.
/// From there, you can add extra `@Collection` annotations to a collection reference
/// for defining sub-collections:
///
/// ```dart
/// @Collection<Person>('persons')
/// @Collection<Friend>('persons/*/friends', name: 'friends') // defines a sub-collection "friends"
/// final personsRef = PersonCollectionReference();
/// ```
///
/// Then, the sub-collection will be available from a document reference:
///
/// ```dart
/// void main() async {
///   PersonDocumentReference johnRef = personsRef.doc('john');
///
///   FriendQuerySnapshot johnFriends = await johnRef.friends.get();
/// }
/// ```
class Collection<T> {
  const Collection(this.path, {this.name});

  Collection.fromJson(Map<Object?, Object?> json)
      : this(
          json['path']! as String,
          name: json['name'] as String?,
        );

  /// The firestore collection path
  final String path;

  final String? name;
}

/// Inject a value from Firestore in the annotated field or property.
///
/// Add this annotation to mutable fields or setters of types that
/// are part of a [Collection].
///
/// See [FirestoreValue] for the types of values that can be injected.
///
/// ```dart
/// @Inject(FirestoreField.id)
/// String? _id;
/// String? get id => _id;
/// ```
class Inject {
  const Inject(this.type);
  final FirestoreValue type;
}

/// Types of values that can be injected using [Inject].
enum FirestoreValue {
  /// Injects the document's id.
  ///
  /// Expects a field of type String or String?.
  id,

  /// Injects the path to the document.
  ///
  /// Expects a field of type String or String?.
  path,

  /// Injects the id of the parent document if the document is in a
  /// subcollection.
  ///
  /// Expects a field of type String or String?.
  /// Use the nullable version if you also use the containing type
  /// in root collections, otherwise the injection will throw.
  parentId,
}
