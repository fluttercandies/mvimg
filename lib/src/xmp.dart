import 'package:xml/xml.dart';

XmpDocument loadXmpDocument(String text){
  return XmpDocument(text);
}

class XmpDocument {
  final String xmp;

  XmpDocument(this.xmp);

  List<XmpElement> getElements() {
    final document = XmlDocument.parse(xmp);
    final root = document.rootElement;
    final rdf = root.getElement('RDF');
    final description = rdf!.getElement('Description');
    return description!.children.map((e) => XmpElement()).toList();
  }
}

class XmpElement {
  List<XmpElement> getChildren() {
    return [];
  }

  String getTag() {
    return '';
  }

  String? getAttribute(String name) {
    return '';
  }
}
