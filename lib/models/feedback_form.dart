import 'package:cloud_firestore/cloud_firestore.dart';

class FeedbackForm {
  String id;
  DateTime timestamp;
  
  // -- HomePage --
  String cpfCnpj;
  String telefoneRep;

  // -- Feedback Expo --
  String opiniaoExpo;
  String expectativasExpo;

  // -- Feedback Representante --
  String suporteRep;
  String futuroRep;
  String motivoNaoFuturoRep;
  String novoRepSelecionado; // <--- NEW FIELD
  String obsEquipe;

  // -- Feedback Montagem --
  String montagemSatisfatoria;
  String obsMontagem;

  // -- Feedback Geral --
  String recomenda;
  String foiFesta;
  String considFesta;
  String msgCeo;

  FeedbackForm({
    required this.id,
    required this.timestamp,
    this.cpfCnpj = '',
    this.telefoneRep = '',
    this.opiniaoExpo = '',
    this.expectativasExpo = '',
    this.suporteRep = '',
    this.futuroRep = '',
    this.motivoNaoFuturoRep = '',
    this.novoRepSelecionado = '', // <--- Init
    this.obsEquipe = '',
    this.montagemSatisfatoria = '',
    this.obsMontagem = '',
    this.recomenda = '',
    this.foiFesta = '',
    this.considFesta = '',
    this.msgCeo = '',
  });

  // Convert to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'timestamp': Timestamp.fromDate(timestamp),
      'cpfCnpj': cpfCnpj,
      'telefoneRep': telefoneRep,
      'opiniaoExpo': opiniaoExpo,
      'expectativasExpo': expectativasExpo,
      'suporteRep': suporteRep,
      'futuroRep': futuroRep,
      'motivoNaoFuturoRep': motivoNaoFuturoRep,
      'novoRepSelecionado': novoRepSelecionado, // <--- Map
      'obsEquipe': obsEquipe,
      'montagemSatisfatoria': montagemSatisfatoria,
      'obsMontagem': obsMontagem,
      'recomenda': recomenda,
      'foiFesta': foiFesta,
      'considFesta': considFesta,
      'msgCeo': msgCeo,
    };
  }

  // Create from Firestore Document
  factory FeedbackForm.fromMap(String id, Map<String, dynamic> map) {
    return FeedbackForm(
      id: id,
      timestamp: (map['timestamp'] as Timestamp).toDate(),
      cpfCnpj: map['cpfCnpj'] ?? '',
      telefoneRep: map['telefoneRep'] ?? '',
      opiniaoExpo: map['opiniaoExpo'] ?? '',
      expectativasExpo: map['expectativasExpo'] ?? '',
      suporteRep: map['suporteRep'] ?? '',
      futuroRep: map['futuroRep'] ?? '',
      motivoNaoFuturoRep: map['motivoNaoFuturoRep'] ?? '',
      novoRepSelecionado: map['novoRepSelecionado'] ?? '', // <--- From Map
      obsEquipe: map['obsEquipe'] ?? '',
      montagemSatisfatoria: map['montagemSatisfatoria'] ?? '',
      obsMontagem: map['obsMontagem'] ?? '',
      recomenda: map['recomenda'] ?? '',
      foiFesta: map['foiFesta'] ?? '',
      considFesta: map['considFesta'] ?? '',
      msgCeo: map['msgCeo'] ?? '',
    );
  }

  dynamic operator [](String key) {
    switch (key) {
      // ... existing cases ...
      case 'novoRepSelecionado': return novoRepSelecionado; // <--- Op
      // ... existing cases ...
      default: return null;
    }
  }
}