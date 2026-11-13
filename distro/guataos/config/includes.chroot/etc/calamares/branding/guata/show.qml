import QtQuick 2.0;
import calamares.slideshow 1.0;

Presentation {
    id: presentation
    Timer { interval: 6000; running: true; repeat: true; onTriggered: presentation.goToNextSlide() }

    Slide {
        Rectangle { anchors.fill: parent; color: "#0a1915" }
        Column {
            anchors.centerIn: parent; spacing: 14
            Text { text: "🥾 guataOS"; color: "#1fae79"; font.pixelSize: 40; font.bold: true; anchors.horizontalCenter: parent.horizontalCenter }
            Text { text: "O Linux brasileiro que caminha com você."; color: "#eaf5ef"; font.pixelSize: 20; anchors.horizontalCenter: parent.horizontalCenter }
        }
    }
    Slide {
        Rectangle { anchors.fill: parent; color: "#0a1915" }
        Column {
            anchors.centerIn: parent; spacing: 12
            Text { text: "Fácil e bonito"; color: "#73f0b8"; font.pixelSize: 30; font.bold: true; anchors.horizontalCenter: parent.horizontalCenter }
            Text { text: "Tudo no clique: clonar disco, gravar pen drive, instalar apps."; color: "#eaf5ef"; font.pixelSize: 18; anchors.horizontalCenter: parent.horizontalCenter }
        }
    }
    Slide {
        Rectangle { anchors.fill: parent; color: "#0a1915" }
        Column {
            anchors.centerIn: parent; spacing: 12
            Text { text: "A Ocara 🛍️"; color: "#f3b457"; font.pixelSize: 30; font.bold: true; anchors.horizontalCenter: parent.horizontalCenter }
            Text { text: "A loja com a nossa cara. Instale o que quiser em 1 clique."; color: "#eaf5ef"; font.pixelSize: 18; anchors.horizontalCenter: parent.horizontalCenter }
        }
    }
}
