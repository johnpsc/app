import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class ConfigSharedPreferences {
  static const usuario = 'usuario';
  static const produtosTelaEntrada = 'produtosTelaEntrada';
  static const produtosTelaSaida = 'produtosTelaSaida';
  static const produtosTelaCompra = 'produtosTelaCompra';
  static const produtosTelaPdv = 'produtosTelaPdv';
  static const produtosTelaNfeSaida = 'produtosTelaNfeSaida';
  static const produtosTelaOrcamento = 'produtosTelaOrcamento';
  static const produtosTelaOS = 'produtosTelaOS';
  static const produtosTelaRepresentante = 'produtosTelaRepresentante';
  static const produtosteladevolucao = 'produtosteladevolucao';
  static const produtosTelanfeentrada = 'produtosTelanfeentrada';

  Future<dynamic> getConexao() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    var conexao = prefs.getString('conexao');
    if (conexao != null) return jsonDecode(conexao);
    return conexao;
  }
}