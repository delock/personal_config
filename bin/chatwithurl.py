import os
import sys
import requests
from openai import OpenAI
from rich.console import Console
from rich.markdown import Markdown
from rich.live import Live
from rich.text import Text

# Initialize Rich console
console = Console()

def fetch_content_from_url(url):
    """Fetch content from a given URL and return it as plain text."""
    try:
        response = requests.get(url, stream=False)
        response.raise_for_status()
        return response.text
    except requests.exceptions.RequestException as e:
        console.print(f"[bold red]Error fetching content from URL:[/bold red] {e}")
        sys.exit(1)

def initialize_openai_client():
    """Initialize the OpenAI client with API key and base URL."""
    api_key = os.getenv("OPENAI_API_KEY")
    base_url = os.getenv("OPENAI_API_URL")
    model = os.getenv("OPENAI_API_MODEL")

    if not api_key or not base_url or not model:
        console.print("[bold red]Error:[/bold red] OPENAI_API_KEY, OPENAI_API_URL, or OPENAI_API_MODEL environment variable not set.")
        sys.exit(1)

    return OpenAI(api_key=api_key, base_url=base_url), model

def ask_question(client, model, content, question):
    """Ask a question to the OpenAI API and return the response."""
    messages = [
        {"role": "system", "content": "You are a helpful assistant."},
        {"role": "user", "content": content},
        {"role": "user", "content": question},
    ]

    try:
        response = client.chat.completions.create(
            model=model,
            messages=messages,
            stream=True
        )
        return response
    except Exception as e:
        console.print(f"[bold red]Error:[/bold red] {e}")
        sys.exit(1)

def stream_response(response):
    """Stream the response from the OpenAI API and beautify it using Rich."""
    markdown_text = ""
    with Live(markdown_text, auto_refresh=True, vertical_overflow="visible") as live:
        for chunk in response:
            if chunk.choices and chunk.choices[0].delta.content:
                markdown_text +=chunk.choices[0].delta.content
                live.update(Markdown(markdown_text))

def main():
    """Main function to run the CLI program."""
    if len(sys.argv) != 2:
        console.print("[bold red]Usage:[/bold red] python script.py <filename or URL>")
        sys.exit(1)

    input_arg = sys.argv[1]

    if input_arg.startswith("http://") or input_arg.startswith("https://"):
        content = fetch_content_from_url(input_arg)
    else:
        try:
            with open(input_arg, 'r') as file:
                content = file.read()
        except FileNotFoundError:
            console.print(f"[bold red]Error:[/bold red] File '{input_arg}' not found.")
            sys.exit(1)

    client, model = initialize_openai_client()

    while True:
        try:
            question = console.input("[bold green]Ask a question:[/bold green] ")
            response = ask_question(client, model, content, question)
            stream_response(response)
        except KeyboardInterrupt:
            console.print("\n[bold cyan]Goodbye![/bold cyan]")
            sys.exit(0)

if __name__ == "__main__":
    main()
