import streamlit as st

def main():
    st.markdown("# Wstęga Newtona")
    
    st.markdown("""
    Projekt z przedmiotu Optymalizacja Nieliniowa. /
        
    Autor: Vitalii Morskyi \
        
    Projekt został zainspirowany opracowaniem 3Blue1Brown, 
    które jest dostępne na [tej stronie](https://www.3blue1brown.com/lessons/newtons-fractal).
    """)

    st.markdown("""
    ### Wprowadzenie
    Przyjmijmy, że potrzebujemy znaleźć rozwiązania równania 
    
    $$f(x) = 0$$, 
    
    gdzie $f(x)$ - dowolny wielomian. 
    Dla przykładu weźmy 
    
    $$f(x) = x^5 + x^2 - x + 1 = (x^2 + 1)(x^3-x+1)$$ 
    
    Zobaczmy jak wygląda wykres funkcji $f(x)$.""")

    st.image("media/function_plot.png", caption="Wykres funkcji f(x).")

    with st.expander("Kod źródłowy w języku Julia"):
        st.code("""using Plots
func1(z) = z^5 + z^2 - z + 1
plot(-2:0.01:2, func1.(-2:0.01:2), xlims=(-4, 4), ylims=(-1.5, 3.5), framestyle = :origin, label="f(x)", aspect_ratio=:equal)
        """, 
        language="julia")

    st.markdown("""
    Jak widzimy, równanie $f(x) = 0$ ma tylko jedno rozwiązanie rzeczywiste w punkcie  $x \\approx -1.32472$.

    ### Rozwiązywanie równań metodą Newtona

    Spróbujmy teraz rozwiązać to równanie za pomocą metody Newtona: 
    
    $$x_{n+1} = x_n - \\frac{f(x)}{f'(x)}$$

    Zobaczmy jak wygląda poszukiwanie pierwiastka równania $f(x) = 0$, jeżeli za punkt początkowy wybieramy $x=-0.95$:
    """)

    st.video(open("media/Hq Root Searching 2.m4v", "rb").read())

    st.markdown("Uruchommy teraz ten sam algorytm, tylko zaczynając od punktu $x=1.3$:")

    st.video(open("media/Hq Root Searching.m4v", "rb").read())

    st.markdown("""
    Jak widzimy, jeżeli zaczynamy w punkcie w pobliżu rozwiązania, to algorytm bardzo szybko dochodzi do rozwiązania. 
    Jeżeli natomiast wybieramy punkty trochę oddalone od pierwiastka, to dość często algorytm zaczyna oscylować wokół 
    minimum lokalnego funkcji. Po niektórej ilość iteracji rozwiązanie jednak się znajduje, ale staje się to tylko dlatego, 
    że algorytm przypadkowo wyrzuca nas w stronę prawdziwego rozwiązania.

    ### Przejście do liczb zespolonych

    Naszą funkcją jest wielomian piątego stopnia. Dla liczb rzeczywistych istnieje tylko jedne rozwiązanie równania $f(x) = 0$. 
    Wiemy jednak, że w przestrzeni liczb zespolonych istnieją wszystkie 5 rozwiązań danego równania. Spróbujmy więc rozwiązać
    to równanie metodą Newtona na przestrzeni liczb zespolonych. 

    Niestety nie możemy pokazać wykresu funkcji $f(x)$ w przestrzeni liczb zespolonych, ponieważ wymagałoby to użycia czterech 
    wymiarów. Możemy natomiast pokazać jak przesuwa się $x$ z każdym krokiem algorytmu w przestrzeni liczb zespolonych. 
    W poniższej animacji przedstawione są poszczególne kroki poszukiwania pierwiastków równania $f(x) = 0$ dla pewnego zbioru 
    liczb zespolonych. 
    """)

    st.video(open("media/Hq Points Cloud.m4v", "rb").read())

    st.markdown("""
    Zróbmy teraz jeszcze ciekawszą animację: z każdym krokiem algorytmu Newtona wyznaczmy do jakiego punktu najbliżej znajduje 
    się każdy punkt. Pokolorujmy teraz te punkty w zależności od ich najbliższego rozwiązania i narysujmy ich w punktach, 
    z których wychodzili. Otrzymujemy bardzo ciekawy wizerunek, który nazywany jest Wstęgą (Fraktalem) Newtona.
    """)

    st.video(open("media/Hq Points Fill.m4v", "rb").read())

    st.markdown("""
    Jak widzimy, na każdej krawędzi dwóch pierwiastków pojawiają się takie dziwne wizerunki, w których obecne są wszystkie kolory. 
    Oznacza to, że z obszaru takiej krawędzi możemy dostać się do dowolnego pierwiastka równania. Nie jest to zbyt oczywiste, 
    dlatego narysujmy najpierw proces poszukiwania pierwiastka metodą Newtona dla jakiegoś zbioru punktów, które znajdują 
    się całkiem  w środku jednego obszaru. Na przykład, niech wszystkie punkty będą z niebieskiego obszaru z powyższej animacji.
    """)

    st.video(open("media/Hq Points No Explosion.m4v", "rb").read())

    st.markdown("""
    Jak widzimy, wszystkie punkty w całkiem oczywisty sposób dążą do najbliższego pierwiastku.

    Zróbmy teraz to samo, tylko zaczynać będziemy z krawędzi obszarów dwóch pierwiastków równania.
    """)

    st.video(open("media/Hq Points Explosion.m4v", "rb").read())

    st.markdown("""
    Jak widzimy, po kilku krokach algorytmu punkty zostają rozrzucone po całej płaszczyźnie.  Możliwie ta animacja trochę lepiej 
    tłumaczy w jaki sposób z krawędzi obszarów dwóch pierwiastków możemy dostać się do każdego pierwiastka równania.

    ### Optymalizacja funkcji metodą Newtona

    Analogicznie do algorytmu poszukiwania pierwiastków równania możemy szukać jego minima i maksima lokalne. 
    Wystarczy po prostu szukać punktów, w których pierwsza pochodna funkcji jest równa zero. Czyli algorytm Newtona dla 
    poszukiwania minimów i maksimów funkcji zapisujemy następująco: 
    
    $$x_{n+1} = x_{n} - \\frac{f'(x)}{f''(x)}$$
    """)


if __name__ == '__main__':
    st.set_page_config(
        page_title="Newton Fractal",
    )
    main()
