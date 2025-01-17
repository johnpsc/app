import 'dart:convert';

import 'package:app/src/essencial/api/dio_cliente.dart';
import 'package:app/src/essencial/api/socket/server.dart';
import 'package:app/src/essencial/provedores/usuario/usuario_provedor.dart';
import 'package:app/src/essencial/provedores/usuario/usuario_servico.dart';
import 'package:app/src/essencial/shared_prefs/chaves_sharedpreferences.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PaginaConfiguracao extends StatefulWidget {
  const PaginaConfiguracao({super.key});

  @override
  State<PaginaConfiguracao> createState() => _PaginaConfiguracaoState();
}

class _PaginaConfiguracaoState extends State<PaginaConfiguracao> {
  final tipoConexaoController = TextEditingController();
  final servidorController = TextEditingController();
  final portaController = TextEditingController();

  final ConfigSharedPreferences _config = ConfigSharedPreferences();

  bool isLoading = false;

  void buscarConexao() async {
    final conexao = await _config.getConexao();

    if (conexao == null) return;

    if (mounted) {
      setState(() {
        tipoConexaoController.text = conexao.tipoConexao;
        servidorController.text = conexao.servidor;
        portaController.text = conexao.porta;
      });
    }
  }

  void verificar() async {
    setState(() => isLoading = true);

    // Future.delayed(const Duration(seconds: 10)).then((value) {
    //   if (mounted) {
    //     ScaffoldMessenger.of(context).hideCurrentSnackBar();
    //     ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
    //       content: Text('Não foi possível conectar a esse Servidor.'),
    //       showCloseIcon: true,
    //       backgroundColor: Colors.red,
    //     ));
    //     setState(() => isLoading = false);
    //   }
    // });

    if (tipoConexaoController.text.isEmpty || servidorController.text.isEmpty || portaController.text.isEmpty) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Campos precisam ser preenchidos'),
        showCloseIcon: true,
      ));
      setState(() => isLoading = false);
      return;
    }

    final SharedPreferences prefs = await SharedPreferences.getInstance();

    await prefs.setString(
      'conexao',
      jsonEncode({
        'tipoConexao': tipoConexaoController.text,
        'servidor': servidorController.text,
        'porta': portaController.text,
      }),
    );

    await prefs.reload();

    DioCliente().configurar(servidor: 'http://${servidorController.text}/sistema/apis_restaurantes/api_restaurantes_venda/');

    // if (tipoConexaoController.text == 'localhost') {
    await conectarAoServidor(servidorController.text, portaController.text);
    // }

    if (mounted) {
      setState(() => isLoading = false);
      var usuario = await UsuarioServico.pegarUsuario(context);
      if (mounted) {
        context.read<UsuarioProvedor>().setUsuario(usuario);
        Navigator.pop(context);
      }
    }
  }

  Future<void> conectarAoServidor(String ip, String porta) async {
    var server = Modular.get<Server>();

    await server.start(ip, porta).then((sucesso) {
      if (sucesso == false) {
        if (mounted) {
          ScaffoldMessenger.of(context).removeCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Não foi possível conectar ao servidor $ip:$porta, mude a conexão e a porta e tente novamente'),
            backgroundColor: Colors.red,
            showCloseIcon: true,
            duration: const Duration(hours: 1),
          ));
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).removeCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Sucesso ao conectar ao servidor $ip:$porta'),
            backgroundColor: Colors.green,
            showCloseIcon: true,
          ));
        }
      }
    });
  }

  @override
  void initState() {
    super.initState();
    buscarConexao();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configurar Conexão'),
        centerTitle: true,
      ),
      body: InkWell(
        focusColor: Colors.transparent,
        splashColor: Colors.transparent,
        splashFactory: NoSplash.splashFactory,
        highlightColor: Colors.transparent,
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: ListView(
            children: [
              DropdownMenu(
                width: MediaQuery.of(context).size.width - 20,
                onSelected: (value) => setState(() => tipoConexaoController.text = value ?? ''),
                label: const Text('Conexão'),
                initialSelection: tipoConexaoController.text,
                dropdownMenuEntries: const [
                  DropdownMenuEntry(value: 'localhost', label: 'Local'),
                  DropdownMenuEntry(value: 'online', label: 'Online'),
                ],
                inputDecorationTheme: const InputDecorationTheme(
                  contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              // if (tipoConexaoController.text == 'localhost') ...[
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: servidorController,
                      onSubmitted: (a) => verificar(),
                      decoration: const InputDecoration(
                        contentPadding: EdgeInsets.all(12),
                        labelText: 'IP do Servidor Local',
                        hintStyle: TextStyle(fontWeight: FontWeight.w300),
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  SizedBox(
                    width: 150,
                    child: TextField(
                      controller: portaController,
                      onSubmitted: (a) => verificar(),
                      decoration: const InputDecoration(
                        contentPadding: EdgeInsets.all(12),
                        labelText: '9980',
                        hintStyle: TextStyle(fontWeight: FontWeight.w300),
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),
              // ],
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton(
                  style: ButtonStyle(
                    backgroundColor: WidgetStateProperty.all(Theme.of(context).colorScheme.inversePrimary),
                    side: const WidgetStatePropertyAll(BorderSide.none),
                    shape: const WidgetStatePropertyAll(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(5)),
                      ),
                    ),
                    textStyle: const WidgetStatePropertyAll(TextStyle(fontSize: 18)),
                  ),
                  onPressed: () => verificar(),
                  child: isLoading ? const CircularProgressIndicator() : const Text('Salvar'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
