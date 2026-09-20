# CASF Framework — self-contained agent framework
# This image packages the whole .claude/ agent system + memory so it can be
# mounted into any AI agent host or used as a volume for CASF Studio.
FROM alpine:3.20

WORKDIR /casf

# The framework is pure Markdown/config — copy everything relevant.
COPY .claude ./claude
COPY CLAUDE.md ./CLAUDE.md
COPY VENTAJAS_COMPETITIVAS.md ./VENTAJAS_COMPETITIVAS.md
COPY PATRON_DE_DISENO.md ./PATRON_DE_DISENO.md
COPY README.md ./README.md

# Mark the volume so host agents can mount it read-only/read-write.
VOLUME ["/casf"]

CMD ["sh"]
