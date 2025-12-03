from langchain_community.chat_models import ChatOpenAI
from langchain.agents import initialize_agent, AgentType
from langchain.memory import ConversationBufferMemory

from langchain.schema import HumanMessage, AIMessage, SystemMessage

from tools import (
    find_books_tool,
    create_order_tool,
    restock_book_tool,
    update_price_tool,
    order_status_tool,
    inventory_summary_tool,
)

from config import OPENAI_API_KEY


def build_agent(previous_messages):
    llm = ChatOpenAI(
        openai_api_key=OPENAI_API_KEY,
        model="gpt-4o-mini",
        temperature=0
    )

    tools = [
        find_books_tool,
        create_order_tool,
        restock_book_tool,
        update_price_tool,
        order_status_tool,
        inventory_summary_tool
    ]

    # REAL memory object
    memory = ConversationBufferMemory(
        memory_key="chat_history",
        return_messages=True
    )

    # Load previous chat history INTO memory
    for msg in previous_messages:
        role = msg["role"]
        content = msg["content"]

        if role == "user":
            memory.chat_memory.add_message(
                HumanMessage(content=content)
            )
        elif role == "assistant":
            memory.chat_memory.add_message(
                AIMessage(content=content)
            )
        elif role == "system":
            memory.chat_memory.add_message(
                SystemMessage(content=content)
            )

    # Build agent with memory
    agent = initialize_agent(
        tools=tools,
        llm=llm,
        agent=AgentType.OPENAI_FUNCTIONS,
        memory=memory,
        verbose=True
    )

    return agent
