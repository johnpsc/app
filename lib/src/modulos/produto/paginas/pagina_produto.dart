import 'package:app/src/essencial/constantes/assets_constantes.dart';
import 'package:app/src/modulos/cardapio/modelos/modelo_produto.dart';
import 'package:app/src/modulos/cardapio/provedores/provedor_carrinho.dart';
import 'package:app/src/modulos/produto/modelos/acompanhamentos_modelo.dart';
import 'package:app/src/modulos/produto/modelos/adicionais_modelo.dart';
import 'package:app/src/modulos/produto/modelos/tamanhos_modelo.dart';
import 'package:app/src/modulos/produto/provedores/provedor_produto.dart';
import 'package:brasil_fields/brasil_fields.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';

class PaginaProduto extends StatefulWidget {
  final ModeloProduto produto;
  final String tipo;
  final String idComanda;
  final String idMesa;
  const PaginaProduto({super.key, required this.produto, required this.tipo, required this.idComanda, required this.idMesa});

  @override
  State<PaginaProduto> createState() => _PaginaProdutoState();
}

class _PaginaProdutoState extends State<PaginaProduto> {
  final ProvedorCarrinho carrinhoProvedor = Modular.get<ProvedorCarrinho>();
  final ProvedorProduto _provedorProduto = Modular.get<ProvedorProduto>();

  bool isLoading = false;

  TextEditingController obsController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _provedorProduto.listarDados(widget.produto.id);
  }

  void selecionarAdicional(AdicionaisModelo item, int index) {
    setState(() => _provedorProduto.listaAdicionais[index].estaSelecionado = !_provedorProduto.listaAdicionais[index].estaSelecionado);
  }

  void selecionarAcompanhamentos(AcompanhamentosModelo item, int index) {
    setState(() => _provedorProduto.listaAcompanhamentos[index].estaSelecionado = !_provedorProduto.listaAcompanhamentos[index].estaSelecionado);
  }

  void inserirNoCarrinho() async {
    final produto = widget.produto;
    final idComanda = widget.idComanda;
    final idMesa = widget.idMesa;

    var comanda = idComanda.isEmpty ? 0 : idComanda;
    var mesa = idMesa.isEmpty ? 0 : idMesa;
    var valor = produto.valorVenda;
    var idProduto = produto.id;
    var observacaoMesa = '';
    var observacao = obsController.text;

    if (_provedorProduto.listaTamanhos.isNotEmpty) {
      if (_provedorProduto.tamanhoSelecionado == null) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text('Selecione um tamanho antes de continuar.'),
          showCloseIcon: true,
        ));

        return;
      }
    }

    setState(() => isLoading = !isLoading);
    await carrinhoProvedor
        .inserir(
      widget.produto,
      widget.tipo,
      mesa,
      comanda,
      valor,
      observacaoMesa,
      idProduto,
      produto.nome,
      _provedorProduto.quantidade,
      observacao,
      _provedorProduto.listaAdicionais.where((e) => e.estaSelecionado == true).toList(),
      _provedorProduto.listaAcompanhamentos.where((e) => e.estaSelecionado == true).toList(),
      _provedorProduto.tamanhoSelecionado,
    )
        .then((sucesso) {
      if (sucesso) {
        if (mounted) Navigator.pop(context);
        return;
      }

      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Ocorreu um erro'),
          showCloseIcon: true,
        ));
      }
    }).whenComplete(() {
      setState(() => isLoading = !isLoading);
    });
  }

  @override
  Widget build(BuildContext context) {
    final produto = widget.produto;

    return GestureDetector(
      onTap: () {
        FocusScopeNode currentFocus = FocusScope.of(context);

        if (!currentFocus.hasPrimaryFocus) {
          currentFocus.unfocus();
        }
      },
      child: AnimatedBuilder(
        animation: _provedorProduto,
        builder: (context, valueProdutoProvedor) {
          return Scaffold(
            appBar: AppBar(
              title: Text("${produto.nome} ${produto.tamanho}"),
              backgroundColor: Theme.of(context).colorScheme.inversePrimary,
            ),
            // backgroundColor: Colors.white,
            floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
            floatingActionButton: FloatingActionButton.extended(
              onPressed: () {
                inserirNoCarrinho();
              },
              label: isLoading
                  ? const CircularProgressIndicator()
                  : Row(
                      children: [
                        const SizedBox(width: 10),
                        // Text('${_provedorProduto.quantidade}x ${double.parse(produto.valorVenda).obterReal()} + ${double.parse(somaAdicionais.valor).obterReal()}'),
                        Text('${_provedorProduto.quantidade}x ${_provedorProduto.retornarTotalPedido(widget.produto.valorVenda).obterReal()}'),
                        const SizedBox(width: 10),
                        const Icon(Icons.check),
                        const SizedBox(width: 10),
                      ],
                    ),
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 20, right: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        produto.foto.isEmpty
                            ? Image.asset(Assets.boxAsset, width: 120, height: 120)
                            : ClipRRect(
                                borderRadius: BorderRadius.circular(8.0),
                                child: CachedNetworkImage(
                                  width: 120,
                                  height: 120,
                                  fit: BoxFit.contain,
                                  fadeOutDuration: const Duration(milliseconds: 100),
                                  placeholder: (context, url) => const SizedBox(
                                    height: 50.0,
                                    width: 50.0,
                                    child: Center(child: CircularProgressIndicator()),
                                  ),
                                  errorWidget: (context, url, error) => const Icon(Icons.error),
                                  imageUrl: produto.foto,
                                ),
                              ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Row(
                              children: [
                                IconButton(
                                  onPressed: () => _provedorProduto.aoDiminuirQuantidade(),
                                  icon: Icon(
                                    Icons.remove_circle_outline,
                                    size: 30,
                                    color: _provedorProduto.quantidade == 1 ? Colors.grey : Colors.red,
                                  ),
                                ),
                                Text(
                                  _provedorProduto.quantidade.toString(),
                                  style: const TextStyle(fontSize: 20),
                                ),
                                IconButton(
                                  onPressed: () => _provedorProduto.aoAumentarQuantidade(),
                                  icon: const Icon(
                                    Icons.add_circle_outline,
                                    size: 30,
                                    color: Colors.green,
                                  ),
                                ),
                              ],
                            ),
                            const Text("Preço", style: TextStyle(fontSize: 18)),
                            Text(
                              _provedorProduto.retornarPrecoProdutoOriginal(widget.produto.valorVenda),
                              style: const TextStyle(color: Colors.green, fontSize: 18),
                            ),
                            const Row(
                              children: [
                                Text("Total", style: TextStyle(fontSize: 18)),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 20, right: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Observações: ', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        Text(
                          _provedorProduto.retornarTotalPedido(widget.produto.valorVenda).obterReal(),
                          style: const TextStyle(color: Colors.green, fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 20, right: 20),
                    child: TextField(
                      controller: obsController,
                      decoration: const InputDecoration(
                        alignLabelWithHint: true,
                        hintText: "Digite alguma observação",
                        hintStyle: TextStyle(fontWeight: FontWeight.w300),
                        border: UnderlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  if (produto.descricao.isNotEmpty) ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Text(
                        produto.descricao,
                        overflow: TextOverflow.fade,
                        maxLines: 6,
                        style: const TextStyle(color: Color.fromARGB(255, 161, 161, 161)),
                      ),
                    ),
                  ],
                  if (_provedorProduto.listaTamanhos.isNotEmpty) ...[
                    Container(
                      padding: const EdgeInsets.only(left: 20, right: 20),
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            blurRadius: 30.0,
                            spreadRadius: -30,
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 7),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Card(
                            margin: EdgeInsets.zero,
                            color: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                            elevation: 0,
                            child: Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(left: 0, top: 10, bottom: 10),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(left: 10),
                                        child: Text(
                                          'Tamanhos (${_provedorProduto.listaTamanhos.length})',
                                          style: const TextStyle(fontSize: 16),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                ListView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: _provedorProduto.listaTamanhos.length,
                                  padding: const EdgeInsets.only(left: 10, right: 10, bottom: 10),
                                  itemBuilder: (context, index) {
                                    var item = _provedorProduto.listaTamanhos[index];

                                    return Card(
                                      child: InkWell(
                                        onTap: () {
                                          _provedorProduto.mudarTamanhoSelecionado(item);
                                        },
                                        borderRadius: const BorderRadius.all(Radius.circular(8)),
                                        child: Padding(
                                          padding: const EdgeInsets.only(top: 5, bottom: 5),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Row(
                                                children: [
                                                  Radio<TamanhosModelo?>(
                                                    value: item,
                                                    groupValue: _provedorProduto.tamanhoSelecionado,
                                                    onChanged: (TamanhosModelo? value) {
                                                      _provedorProduto.mudarTamanhoSelecionado(item);
                                                    },
                                                  ),
                                                  Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Text(item.nome),
                                                      Text(
                                                        double.parse(item.valor).obterReal(),
                                                        style: const TextStyle(color: Colors.green),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                  if (_provedorProduto.listaAcompanhamentos.isNotEmpty) ...[
                    Container(
                      padding: const EdgeInsets.only(left: 20, right: 20),
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            blurRadius: 30.0,
                            spreadRadius: -30,
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 10),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(5),
                          child: ExpansionPanelList(
                            expandedHeaderPadding: const EdgeInsets.all(0),
                            expansionCallback: (int index, bool isExpanded) {
                              _provedorProduto.mudarExpandido1(isExpanded);
                            },
                            children: [
                              ExpansionPanel(
                                backgroundColor: Colors.white,
                                isExpanded: _provedorProduto.expandido1,
                                canTapOnHeader: true,
                                headerBuilder: (context, isExpanded) {
                                  return Row(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(left: 10),
                                        child: Text(
                                          'Acompanhamentos (${_provedorProduto.listaAcompanhamentos.length})',
                                          style: const TextStyle(fontSize: 16),
                                        ),
                                      ),
                                    ],
                                  );
                                },
                                body: ListView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: _provedorProduto.listaAcompanhamentos.length,
                                  padding: const EdgeInsets.only(left: 10, right: 10, bottom: 10),
                                  itemBuilder: (context, index) {
                                    var item = _provedorProduto.listaAcompanhamentos[index];

                                    return Card(
                                      child: InkWell(
                                        onTap: () => selecionarAcompanhamentos(item, index),
                                        borderRadius: const BorderRadius.all(Radius.circular(8)),
                                        child: Padding(
                                          padding: const EdgeInsets.only(top: 5, bottom: 5),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Row(
                                                children: [
                                                  Checkbox(
                                                    value: _provedorProduto.listaAcompanhamentos.where((element) => element.estaSelecionado == true).contains(item),
                                                    onChanged: (value) {
                                                      selecionarAcompanhamentos(item, index);
                                                    },
                                                  ),
                                                  Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Text(item.nome),
                                                      Text(
                                                        double.parse(item.valor) == 0 ? 'Grátis' : double.parse(item.valor).obterReal(),
                                                        style: const TextStyle(color: Colors.green),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
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
                        ),
                      ),
                    ),
                  ],
                  if (_provedorProduto.listaAdicionais.isNotEmpty) ...[
                    Padding(
                      padding: const EdgeInsets.only(left: 20, right: 20),
                      // decoration: BoxDecoration(
                      //   boxShadow: [
                      //     BoxShadow(
                      //       color: Colors.grey.withOpacity(0.5),
                      //       blurRadius: 30.0,
                      //       spreadRadius: -30,
                      //     ),
                      //   ],
                      // ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Adicionais (${_provedorProduto.listaAdicionais.length})',
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 10),
                          SizedBox(
                            child: ListView.builder(
                              physics: const NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              itemCount: _provedorProduto.listaAdicionais.length,
                              itemBuilder: (context, index) {
                                final item = _provedorProduto.listaAdicionais[index];

                                return Column(
                                  children: [
                                    Stack(
                                      children: [
                                        Card(
                                          margin: EdgeInsets.zero,
                                          child: InkWell(
                                            onTap: () => selecionarAdicional(item, index),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Row(
                                                  children: [
                                                    item.foto.isEmpty
                                                        ? Image.asset(Assets.produtoAsset, width: 70, height: 70)
                                                        : ClipRRect(
                                                            borderRadius: BorderRadius.circular(8.0),
                                                            child: CachedNetworkImage(
                                                              width: 70,
                                                              height: 70,
                                                              fit: BoxFit.contain,
                                                              fadeOutDuration: const Duration(milliseconds: 100),
                                                              placeholder: (context, url) => const SizedBox(
                                                                height: 70,
                                                                width: 70,
                                                                child: Center(child: CircularProgressIndicator()),
                                                              ),
                                                              errorWidget: (context, url, error) => const Icon(Icons.error),
                                                              imageUrl: item.foto,
                                                            ),
                                                          ),
                                                    const SizedBox(width: 5),
                                                    Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                      children: [
                                                        Text(
                                                          item.nome,
                                                          style: const TextStyle(fontSize: 15),
                                                        ),
                                                        Text(
                                                          double.parse(item.valor).obterReal(),
                                                          style: const TextStyle(
                                                            fontSize: 15,
                                                            color: Colors.green,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                                if (_provedorProduto.listaAdicionais.firstWhere((element) => element.id == item.id).estaSelecionado) ...[
                                                  Row(
                                                    children: [
                                                      IconButton(
                                                        onPressed: () {
                                                          if (item.quantidade > 1) {
                                                            setState(() => --item.quantidade);
                                                          }
                                                        },
                                                        icon: Icon(
                                                          Icons.remove_circle_outline,
                                                          size: 30,
                                                          color: item.quantidade == 1 ? Colors.grey : Colors.red,
                                                        ),
                                                      ),
                                                      Text(
                                                        item.quantidade.toString(),
                                                        style: const TextStyle(fontSize: 20),
                                                      ),
                                                      IconButton(
                                                        onPressed: () {
                                                          setState(() => item.quantidade++);
                                                        },
                                                        icon: const Icon(
                                                          Icons.add_circle_outline,
                                                          size: 30,
                                                          color: Colors.green,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ]
                                              ],
                                            ),
                                          ),
                                        ),
                                        if (item.estaSelecionado) ...[
                                          const Positioned(
                                            top: -10,
                                            left: -10,
                                            child: Icon(Icons.check, size: 90, color: Colors.green),
                                          ),
                                        ],
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                  ],
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
