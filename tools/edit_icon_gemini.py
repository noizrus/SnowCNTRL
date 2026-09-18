#!/usr/bin/env python3
"""Modifie une image avec le modele d'edition d'image de Gemini.

Installation :
    pip install google-genai

Cle API :
    Cree une cle sur https://aistudio.google.com/apikey puis :
    export GEMINI_API_KEY="ta-cle"

Exemple :
    python edit_icon_gemini.py icone_source.jpg icone_app.png
    python edit_icon_gemini.py icone_source.jpg icone_app.png --prompt "..."
"""
import argparse
import os
import sys
from pathlib import Path

from google import genai
from google.genai import types

DEFAULT_PROMPT = (
    "Transforme cette image en icone d'application mobile : format carre, "
    "sans aucun texte ni mot lisible, sans reference a une province ou "
    "ville en particulier. Garde uniquement un symbole simple et fort : "
    "un flocon de neige stylise combine a une silhouette de lame de "
    "charrue a neige, dans des tons rouge et orange sur un fond uni. "
    "Style icone plate, moderne, contrastee, lisible meme a tres petite "
    "taille (comme sur un ecran d'accueil de telephone). Aucun element "
    "photorealiste, aucun animal, aucun arriere-plan complexe."
)


def edit_image(input_path: str, output_path: str, prompt: str, model: str) -> None:
    api_key = os.environ.get("GEMINI_API_KEY")
    if not api_key:
        sys.exit("GEMINI_API_KEY n'est pas defini. Fais : export GEMINI_API_KEY=ta-cle")

    client = genai.Client(api_key=api_key)

    src = Path(input_path)
    image_bytes = src.read_bytes()
    mime_type = "image/png" if src.suffix.lower() == ".png" else "image/jpeg"

    response = client.models.generate_content(
        model=model,
        contents=[
            types.Part.from_bytes(data=image_bytes, mime_type=mime_type),
            prompt,
        ],
    )

    saved = False
    for part in response.candidates[0].content.parts:
        if getattr(part, "inline_data", None) is not None:
            Path(output_path).write_bytes(part.inline_data.data)
            saved = True
        elif getattr(part, "text", None):
            print("Gemini:", part.text)

    if not saved:
        sys.exit("Aucune image renvoyee par Gemini — ajuste le prompt et reessaie.")

    print(f"Image sauvegardee : {output_path}")


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Modifier une image avec Gemini")
    parser.add_argument("input", help="Chemin de l'image source")
    parser.add_argument("output", help="Chemin de l'image generee")
    parser.add_argument("--prompt", default=DEFAULT_PROMPT, help="Instruction envoyee a Gemini")
    parser.add_argument("--model", default="gemini-2.5-flash-image", help="Modele Gemini a utiliser")
    args = parser.parse_args()
    edit_image(args.input, args.output, args.prompt, args.model)
