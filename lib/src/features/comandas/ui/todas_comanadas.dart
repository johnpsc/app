import 'package:app/src/features/comandas/interactor/states/comandas_state.dart';
import 'package:app/src/features/comandas/ui/nova_comanda.dart';
import 'package:flutter/material.dart';

class TodasComandas extends StatefulWidget {
  const TodasComandas({super.key});

  @override
  State<TodasComandas> createState() => _TodasComandasState();
}

class _TodasComandasState extends State<TodasComandas> {
  final ComandasState _state = ComandasState();
  bool isLoading = false;

  final pesquisaController = TextEditingController();

  void listarComandas() async {
    setState(() => isLoading = !isLoading);
    await _state.listarComandas();
    setState(() => isLoading = !isLoading);
  }

  @override
  void initState() {
    super.initState();

    listarComandas();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Comandas'),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            showDragHandle: true,
            builder: (context) => const NovaComanda(),
          );
        },
        child: const Icon(Icons.add),
      ),
      body: ValueListenableBuilder(
        valueListenable: comandasState,
        builder: (context, value, child) {
          final listaComandas = [
            ...value[0].comandas,
            ...value[1].comandas,
          ];

          return Padding(
            padding: const EdgeInsets.only(left: 10, right: 10, top: 10),
            child: Column(
              children: [
                TextField(
                  controller: pesquisaController,
                  decoration: const InputDecoration(
                    hintText: 'Pesquisa',
                    contentPadding: EdgeInsets.all(13),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                value.isEmpty
                    ? Expanded(
                        child: ListView(children: const [
                        SizedBox(height: 50),
                        Center(child: Text('Não há Comandas')),
                      ]))
                    : Expanded(
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: listaComandas.length,
                          itemBuilder: (context, index) {
                            // if (value.length == index) {
                            //   return const SizedBox(height: 100, child: Center(child: Text('Fim da lista')));
                            // }
                            final item = listaComandas[index];

                            return SizedBox(
                              height: 110,
                              child: Card(
                                child: InkWell(
                                  onTap: () {},
                                  borderRadius: const BorderRadius.all(Radius.circular(8)),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            width: 5,
                                            clipBehavior: Clip.hardEdge,
                                            decoration: const BoxDecoration(
                                              borderRadius: BorderRadius.only(
                                                topLeft: Radius.circular(8),
                                                bottomLeft: Radius.circular(8),
                                              ),
                                            ),
                                            child: VerticalDivider(
                                              color: item.ativo == 'Sim' ? Colors.green : Colors.red,
                                              thickness: 5,
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(10),
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text('ID: ${item.id}'),
                                                Text('Nome: ${item.nome}'),
                                                Text('Cliente: ${item.nomeCliente}'),
                                                Text('Mesa: ${item.nomeMesa}'),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      Column(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: SizedBox(
                                              width: 50,
                                              child: InkWell(
                                                  onTap: () async {
                                                    final res = await _state.editarAtivo(item.id, item.ativo == 'Sim' ? 'Não' : 'Sim');

                                                    if (mounted && !res) {
                                                      ScaffoldMessenger.of(context).hideCurrentSnackBar();
                                                      ScaffoldMessenger.of(context).showSnackBar(
                                                        const SnackBar(
                                                          content: Text('Ocorreu um erro!'),
                                                          showCloseIcon: true,
                                                        ),
                                                      );
                                                    }
                                                  },
                                                  borderRadius: const BorderRadius.only(topRight: Radius.circular(8)),
                                                  child: item.ativo == 'Sim'
                                                      ? const Icon(Icons.check_box_outlined)
                                                      : const Icon(Icons.check_box_outline_blank_rounded)),
                                            ),
                                          ),
                                          Expanded(
                                            child: MenuAnchor(
                                              builder: (context, controller, child) {
                                                return SizedBox(
                                                  width: 50,
                                                  child: InkWell(
                                                    onTap: () {
                                                      if (controller.isOpen) {
                                                        controller.close();
                                                      } else {
                                                        controller.open();
                                                      }
                                                    },
                                                    borderRadius: const BorderRadius.only(bottomRight: Radius.circular(8)),
                                                    child: const Icon(Icons.more_vert),
                                                  ),
                                                );
                                              },
                                              menuChildren: [
                                                MenuItemButton(
                                                  onPressed: () {
                                                    showModalBottomSheet(
                                                      context: context,
                                                      isScrollControlled: true,
                                                      showDragHandle: true,
                                                      builder: (context) => const NovaComanda(),
                                                    );
                                                  },
                                                  child: const Text('Editar Comanda'),
                                                ),
                                                MenuItemButton(
                                                  onPressed: () async {
                                                    showDialog(
                                                      context: context,
                                                      builder: (context) => Dialog(
                                                        child: ListView(
                                                          padding: const EdgeInsets.all(20),
                                                          shrinkWrap: true,
                                                          children: [
                                                            const Text(
                                                              'Deseja realmente excluir?',
                                                              style: TextStyle(fontSize: 20),
                                                            ),
                                                            const SizedBox(height: 15),
                                                            Expanded(
                                                              child: Row(
                                                                mainAxisAlignment: MainAxisAlignment.end,
                                                                children: [
                                                                  TextButton(
                                                                    onPressed: () {
                                                                      Navigator.pop(context);
                                                                    },
                                                                    child: const Text('Carcelar'),
                                                                  ),
                                                                  const SizedBox(width: 10),
                                                                  TextButton(
                                                                    onPressed: () async {
                                                                      final res = await _state.excluirComanda(item.id);

                                                                      if (mounted) {
                                                                        Navigator.pop(context);
                                                                      }

                                                                      if (mounted && !res['sucesso']) {
                                                                        ScaffoldMessenger.of(context).hideCurrentSnackBar();
                                                                        ScaffoldMessenger.of(context).showSnackBar(
                                                                          SnackBar(
                                                                            content: Text(res['mensagem'] ?? 'Ocorreu um erro!'),
                                                                            showCloseIcon: true,
                                                                          ),
                                                                        );
                                                                      }
                                                                    },
                                                                    child: const Text('excluir'),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                  child: const Text('Excluir Comanda'),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
              ],
            ),
          );
        },
      ),
    );
  }
}
