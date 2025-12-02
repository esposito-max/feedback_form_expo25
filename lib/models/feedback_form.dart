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
  String obsEquipe;

  // -- Feedback Montagem --
  String montagemSatisfatoria;
  String obsMontagem;

  // -- Feedback Geral --
  String recomenda;

  FeedbackForm({
    required this.id,
    required this.timestamp,
    this.cpfCnpj = '',
    this.telefoneRep = '',
    this.opiniaoExpo = '',
    this.expectativasExpo = '',
    this.suporteRep = '',
    this.futuroRep = '',
    this.obsEquipe = '',
    this.montagemSatisfatoria = '',
    this.obsMontagem = '',
    this.recomenda = '',
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
      'obsEquipe': obsEquipe,
      'montagemSatisfatoria': montagemSatisfatoria,
      'obsMontagem': obsMontagem,
      'recomenda': recomenda,
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
      obsEquipe: map['obsEquipe'] ?? '',
      montagemSatisfatoria: map['montagemSatisfatoria'] ?? '',
      obsMontagem: map['obsMontagem'] ?? '',
      recomenda: map['recomenda'] ?? '',
    );
  }

  // Operator for dynamic access
  dynamic operator [](String key) {
    switch (key) {
      case 'cpfCnpj': return cpfCnpj;
      case 'telefoneRep': return telefoneRep;
      case 'opiniaoExpo': return opiniaoExpo;
      case 'expectativasExpo': return expectativasExpo;
      case 'suporteRep': return suporteRep;
      case 'futuroRep': return futuroRep;
      case 'obsEquipe': return obsEquipe;
      case 'montagemSatisfatoria': return montagemSatisfatoria;
      case 'obsMontagem': return obsMontagem;
      case 'recomenda': return recomenda;
      default: return null;
    }
  }
}