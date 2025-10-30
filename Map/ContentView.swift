    //  ContentView.swift
    //  02.8 - Interface Simples com MapKit
    //
    //  Created by Uriel on 19/03/25.
    //

    // Importa o framework SwiftUI para construir interfaces de usuário
import SwiftUI
    // Importa o framework MapKit para funcionalidades de mapas e localização
import MapKit

    // MARK: - Estrutura Principal da View
    // Define a estrutura ContentView que conforma ao protocolo View do SwiftUI
    // Esta será a view principal do nosso aplicativo
struct ContentView: View {
    
        // MARK: - Propriedades do Estado
        // @State é usado para propriedades que, quando alteradas, fazem a view ser recarregada
        // O SwiftUI automaticamente observa mudanças nessas propriedades
    
        // Controla a região visível do mapa (centro e zoom)
    @State private var region = MKCoordinateRegion(
        // Define o centro do mapa com coordenadas específicas
        center: CLLocationCoordinate2D(
            latitude: -23.5505,  // Latitude de São Paulo
            longitude: -46.6333   // Longitude de São Paulo
        ),
        // Define o nível de zoom do mapa (span)
        span: MKCoordinateSpan(
            latitudeDelta: 0.01,  // Quanto menor o valor, mais zoom (mais próximo)
            longitudeDelta: 0.01   // Controla a amplitude horizontal visível
        )
    )
    
        // Controla o tipo de visualização do mapa (padrão, satélite, híbrido)
    @State private var mapType: MKMapType = .standard
    
        // Controla se a localização do usuário será mostrada no mapa
    @State private var showUserLocation = false
    
        // Controla se pontos de interesse (restaurantes, lojas, etc.) serão mostrados
    @State private var showPointsOfInterest = true
    
        // Armazena todas as anotações (marcadores/pins) que serão exibidas no mapa
    @State private var annotations: [MapAnnotationItem] = []
    
        // Controla se o seletor de tipo de mapa está visível
    @State private var showingMapTypeSelector = false
    
        // Controla se o usuário está no modo de adicionar novos pins ao mapa
    @State private var isAddingPin = false
    
        // A propriedade body define a interface do usuário
        // some View significa que retorna algum tipo que conforma com o protocolo View
    var body: some View {
            // NavigationView fornece uma barra de navegação no topo da tela
        NavigationView {
                // VStack organiza as views verticalmente
                // spacing: 0 significa sem espaçamento entre as views
            VStack(spacing: 0) {
                
                    // MARK: - Mapa Principal
                    // A view Map é o componente principal que exibe o mapa
                Map(
                    // coordinateRegion: Liga a região visível do mapa à variável region
                    // O $ indica uma ligação bidirecional (binding)
                    coordinateRegion: $region,
                    // interactionModes: Quais interações são permitidas com o mapa
                    // .all permite todas as interações (zoom, rotação, movimento)
                    interactionModes: .all,
                    // showsUserLocation: Se deve mostrar a localização do usuário
                    showsUserLocation: showUserLocation,
                    // userTrackingMode: Como o mapa rastreia a localização do usuário
                    // .none significa que não segue automaticamente
                    userTrackingMode: .none,
                    // annotationItems: A lista de anotações (pins) a serem exibidas
                    annotationItems: annotations
                ) { annotation in
                        // MARK: - Anotações Personalizadas
                        // MapAnnotation define como cada marcador/pin é exibido no mapa
                    MapAnnotation(coordinate: annotation.coordinate) {
                            // VStack organiza o ícone e o texto verticalmente
                        VStack {
                                // Button torna o pin clicável
                            Button(action: {
                                    // Ao clicar no pin, chama a função para removê-lo
                                deleteAnnotation(annotation)
                            }) {
                                    // Image exibe um ícone do sistema (SF Symbols)
                                Image(systemName: annotation.iconName)
                                    // Define a cor do ícone
                                    .foregroundColor(annotation.color)
                                    // Define o tamanho da fonte
                                    .font(.title2)
                                    // Adiciona um fundo branco atrás do ícone
                                    .background(
                                        Circle()
                                            .fill(.white)
                                            .frame(width: 30, height: 30)
                                    )
                                    // Adiciona uma sombra sutil
                                    .shadow(radius: 2)
                            }
                            
                                // Text exibe o título abaixo do pin
                            Text(annotation.title)
                                .font(.caption) // Fonte pequena
                                .padding(.horizontal, 8) // Espaçamento horizontal
                                .padding(.vertical, 4) // Espaçamento vertical
                                .background(.white) // Fundo branco
                                .cornerRadius(8) // Cantos arredondados
                                .shadow(radius: 1) // Sombra sutil
                        }
                    }
                }
                    // Define o estilo visual do mapa baseado na seleção do usuário
                .mapStyle(mapType == .satellite ? .hybrid : .standard)
                    // Adiciona um reconhecedor de toque no mapa
                .onTapGesture {
                        // Se estiver no modo de adição, adiciona um pin no centro do mapa
                    if isAddingPin {
                        addPinAtCenterLocation()
                    }
                }
                    // Executa código quando a view aparece pela primeira vez
                .onAppear {
                        // Configura pins iniciais de exemplo
                    setupInitialAnnotations()
                }
                
                    // MARK: - Painel de Controles
                    // Cria um painel vertical de controles abaixo do mapa
                VStack(spacing: 16) {
                    
                        // MARK: - Seletor de Tipo de Mapa
                        // HStack organiza os elementos horizontalmente
                    HStack {
                            // Texto descritivo
                        Text("Tipo de Mapa:")
                            .font(.headline) // Fonte em destaque
                        
                            // Spacer cria um espaço flexível que empurra os elementos para as extremidades
                        Spacer()
                        
                            // Botão para mostrar o seletor de tipos de mapa
                        Button(action: {
                                // Ativa o flag para mostrar o seletor
                            showingMapTypeSelector = true
                        }) {
                                // HStack organiza ícone e texto horizontalmente
                            HStack {
                                    // Ícone que muda conforme o tipo de mapa selecionado
                                Image(systemName: mapType == .standard ? "map" : "map.fill")
                                    // Texto que muda conforme o tipo de mapa selecionado
                                Text(mapType == .standard ? "Padrão" : "Satélite")
                            }
                            .padding(.horizontal, 16) // Espaçamento horizontal
                            .padding(.vertical, 8) // Espaçamento vertical
                            .background(.blue) // Fundo azul
                            .foregroundColor(.white) // Texto branco
                            .cornerRadius(8) // Cantos arredondados
                        }
                    }
                    .padding(.horizontal) // Adiciona padding horizontal
                    
                        // MARK: - Controles de Funcionalidade
                    HStack(spacing: 20) {
                        
                            // Botão para mostrar/ocultar localização do usuário
                        VStack {
                            Button(action: {
                                    // Alterna o valor entre true e false
                                showUserLocation.toggle()
                            }) {
                                VStack {
                                        // Ícone que muda conforme o estado
                                    Image(systemName: showUserLocation ? "location.fill" : "location")
                                        .font(.title2)
                                    Text("Minha Localização")
                                        .font(.caption)
                                }
                                .frame(width: 80, height: 60) // Tamanho fixo
                                .background(showUserLocation ? .green : .gray) // Cor muda com o estado
                                .foregroundColor(.white) // Texto branco
                                .cornerRadius(12) // Cantos arredondados
                            }
                        }
                        
                            // Botão para mostrar/ocultar pontos de interesse
                        VStack {
                            Button(action: {
                                showPointsOfInterest.toggle()
                            }) {
                                VStack {
                                    Image(systemName: showPointsOfInterest ? "mappin.circle.fill" : "mappin.circle")
                                        .font(.title2)
                                    Text("Marcos")
                                        .font(.caption)
                                }
                                .frame(width: 80, height: 60)
                                .background(showPointsOfInterest ? .orange : .gray)
                                .foregroundColor(.white)
                                .cornerRadius(12)
                            }
                        }
                        
                            // Botão para ativar/desativar modo de adição de pins
                        VStack {
                            Button(action: {
                                isAddingPin.toggle()
                            }) {
                                VStack {
                                    Image(systemName: isAddingPin ? "plus.circle.fill" : "plus.circle")
                                        .font(.title2)
                                    Text(isAddingPin ? "Cancelar" : "Adicionar Pin")
                                        .font(.caption)
                                }
                                .frame(width: 80, height: 60)
                                .background(isAddingPin ? .orange : .blue)
                                .foregroundColor(.white)
                                .cornerRadius(12)
                            }
                        }
                        
                            // Botão para centralizar o mapa em São Paulo
                        VStack {
                            Button(action: {
                                centerMapOnSãoPaulo()
                            }) {
                                VStack {
                                    Image(systemName: "location.circle")
                                        .font(.title2)
                                    Text("Centralizar")
                                        .font(.caption)
                                }
                                .frame(width: 80, height: 60)
                                .background(.purple)
                                .foregroundColor(.white)
                                .cornerRadius(12)
                            }
                        }
                    }
                    .padding(.horizontal)
                    
                        // MARK: - Controles de Limpeza
                    HStack(spacing: 20) {
                            // Botão para limpar todos os pins
                        Button(action: {
                            clearAllAnnotations()
                        }) {
                            HStack {
                                Image(systemName: "trash")
                                    .font(.title3)
                                Text("Limpar Todos os Pins")
                                    .font(.caption)
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(.red)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                        }
                            // Desativa o botão se não houver pins
                        .disabled(annotations.isEmpty)
                        
                        Spacer()
                        
                            // Texto informativo para o usuário
                        VStack(alignment: .trailing) {
                            Text("Toque em um pin para excluí-lo")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                                .italic()
                            
                                // Mostra instrução adicional quando no modo de adição
                            if isAddingPin {
                                Text("👆 Toque no mapa para adicionar pin no centro")
                                    .font(.caption2)
                                    .foregroundColor(.orange)
                                    .bold()
                            }
                        }
                    }
                    .padding(.horizontal)
                    
                        // MARK: - Informações do Mapa
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Informações do Mapa:")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        HStack {
                            VStack(alignment: .leading) {
                                    // Exibe a latitude atual do centro do mapa
                                Text("Latitude: \(String(format: "%.4f", region.center.latitude))")
                                    // Exibe a longitude atual do centro do mapa
                                Text("Longitude: \(String(format: "%.4f", region.center.longitude))")
                            }
                            .font(.caption)
                            .foregroundColor(.secondary)
                            
                            Spacer()
                            
                            VStack(alignment: .trailing) {
                                    // Exibe o nível de zoom atual
                                Text("Zoom: \(String(format: "%.4f", region.span.latitudeDelta))")
                                    // Exibe a quantidade de anotações no mapa
                                Text("Anotações: \(annotations.count)")
                            }
                            .font(.caption)
                            .foregroundColor(.secondary)
                        }
                        .padding(.horizontal)
                    }
                    .padding(.bottom)
                }
                .background(Color(.systemGray6)) // Cor de fundo do painel
            }
            .navigationTitle("MapKit Educacional") // Título na barra de navegação
            .navigationBarTitleDisplayMode(.large) // Modo de exibição do título
            .toolbar {
                    // Adiciona um botão na barra de navegação
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Ajuda") {
                        showingMapTypeSelector = true
                    }
                }
            }
        }
            // ActionSheet que aparece quando showingMapTypeSelector é true
        .actionSheet(isPresented: $showingMapTypeSelector) {
            ActionSheet(
                title: Text("Selecionar Tipo de Mapa"),
                message: Text("Escolha como você quer visualizar o mapa"),
                buttons: [
                    .default(Text("Padrão")) {
                        mapType = .standard
                    },
                    .default(Text("Satélite")) {
                        mapType = .satellite
                    },
                    .default(Text("Híbrido")) {
                        mapType = .hybrid
                    },
                    .cancel() // Botão para cancelar
                ]
            )
        }
    }
    
        // MARK: - Métodos de Configuração
    
        /// Configura as anotações iniciais do mapa (exemplos)
    private func setupInitialAnnotations() {
            // Cria algumas anotações de exemplo para demonstrar o funcionamento
        let initialAnnotations = [
            MapAnnotationItem(
                coordinate: CLLocationCoordinate2D(latitude: -23.5505, longitude: -46.6333),
                title: "Centro de São Paulo",
                iconName: "building.2",
                color: .red
            ),
            MapAnnotationItem(
                coordinate: CLLocationCoordinate2D(latitude: -23.5882, longitude: -46.6564),
                title: "Parque Ibirapuera",
                iconName: "leaf",
                color: .green
            ),
            MapAnnotationItem(
                coordinate: CLLocationCoordinate2D(latitude: -23.5475, longitude: -46.6391),
                title: "Museu de Arte",
                iconName: "building.columns",
                color: .blue
            )
        ]
        
            // Atribui as anotações iniciais à propriedade annotations
        annotations = initialAnnotations
    }
    
        /// Centraliza o mapa na cidade de São Paulo
    private func centerMapOnSãoPaulo() {
            // withAnimation torna a transição suave
        withAnimation(.easeInOut(duration: 1.0)) {
                // Define o centro do mapa para as coordenadas de São Paulo
            region.center = CLLocationCoordinate2D(
                latitude: -23.5505,
                longitude: -46.6333
            )
                // Define o nível de zoom
            region.span = MKCoordinateSpan(
                latitudeDelta: 0.01,
                longitudeDelta: 0.01
            )
        }
    }
    
        /// Remove uma anotação específica do mapa
    private func deleteAnnotation(_ annotation: MapAnnotationItem) {
            // withAnimation torna a remoção suave
        withAnimation(.easeInOut(duration: 0.3)) {
                // Filtra o array removendo a anotação com o ID correspondente
            annotations.removeAll { $0.id == annotation.id }
        }
    }
    
        /// Remove todas as anotações do mapa
    private func clearAllAnnotations() {
            // withAnimation torna a remoção suave
        withAnimation(.easeInOut(duration: 0.5)) {
                // Remove todas as anotações do array
            annotations.removeAll()
        }
    }
    
        /// Adiciona um pin em uma coordenada específica
    private func addPinAtCoordinate(_ coordinate: CLLocationCoordinate2D) {
            // Cria uma nova anotação com coordenada, título, ícone e cor aleatória
        let newAnnotation = MapAnnotationItem(
            coordinate: coordinate,
            title: "Pin \(annotations.count + 1)",
            iconName: "mappin",
            color: [.red, .blue, .green, .orange, .purple, .pink].randomElement() ?? .red
        )
        
            // withAnimation torna a adição suave
        withAnimation(.easeInOut(duration: 0.3)) {
                // Adiciona a nova anotação ao array
            annotations.append(newAnnotation)
        }
        
            // Desativa o modo de adição após adicionar o pin
        isAddingPin = false
    }
    
        /// Adiciona um pin no centro atual do mapa
    private func addPinAtCenterLocation() {
            // Obtém as coordenadas do centro atual do mapa
        let coordinate = region.center
            // Chama a função para adicionar o pin nessas coordenadas
        addPinAtCoordinate(coordinate)
    }
}

    // MARK: - Modelo de Dados para Anotações
    /// Estrutura que representa uma anotação no mapa
struct MapAnnotationItem: Identifiable {
    let id = UUID() // Identificador único para cada anotação
    let coordinate: CLLocationCoordinate2D // Coordenadas geográficas (latitude e longitude)
    let title: String // Título que aparece abaixo do pin
    let iconName: String // Nome do ícone do SF Symbols
    let color: Color // Cor do ícone
}

    // MARK: - Preview da View
    // Permite visualizar a view no Xcode sem executar o app completo
#Preview {
    ContentView()
}
