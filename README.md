## Script `RepararHardware.ps1`

Este script automatiza o procedimento que você normalmente faria manualmente no **Gerenciador de Dispositivos** quando algum hardware aparece com erro (ícone de exclamação), como placa de vídeo, placa de som, componentes ACPI etc.

### O que o script faz

- **Identifica dispositivos com falha**  
  - Usa `Get-PnpDevice` para listar os dispositivos presentes.  
  - Filtra todos os que **não** estão com status `OK`.  
  - Opcionalmente, você pode limitar por classes de dispositivos usando o array `$allowedClasses` dentro do script (por exemplo apenas `Display`, `Media`, `System`).

- **Mostra uma tabela com os dispositivos problemáticos**  
  - Exibe `Class`, `FriendlyName`, `InstanceId` e `Status` para você conferir.

- **Pede confirmação antes de remover**  
  - Pergunta: `Deseja remover esses dispositivos para forçar reinstalação? (S/N)`  
  - Se você responder `S`/`s` (ou `Y`/`y`), ele continua.  
  - Qualquer outra resposta cancela a operação.

- **Remove os dispositivos com falha (sem remover drivers)**  
  - Usa `Remove-PnpDevice -InstanceId ... -Confirm:$false`.  
  - Isso remove o “device node” do sistema, mas **não desinstala o driver**.

- **Força uma nova varredura de hardware**  
  - Executa `pnputil /scan-devices`.  
  - O Windows detecta novamente os dispositivos removidos e os recria usando os drivers já instalados.

### Pré-requisitos

- **PowerShell executado como Administrador**.  
- Windows 10/11 (módulo `PnpDevice` já incluso).  
- `pnputil` disponível no sistema (já vem com o Windows).

### Como usar

1. **Abra o PowerShell como Administrador**
   - Clique com o botão direito em `Windows PowerShell` ou `Terminal` → **Executar como administrador**.

2. **Navegue até a pasta do script**

   ```powershell
   cd "c:\caminho_para_o_script\ps_script_hardware_fail"
   ```

3. **(Opcional) Ajuste o filtro de classes**
   - Edite o arquivo `RepararHardware.ps1`.  
   - No início do script há o array `$allowedClasses`:

     ```powershell
     $allowedClasses = @(
         # "Display",   # Placa de vídeo
         # "Media",     # Áudio
         # "System"     # Componentes de sistema (ACPI, etc.)
     )
     ```

   - Para **limitar** o script, remova o `#` das classes que você quer considerar.  
   - Se deixar o array vazio (como está), ele pega **todos** os dispositivos com erro, de qualquer classe.

4. **Execute o script**

   ```powershell
   .\RepararHardware.ps1
   ```

5. **Confirme a remoção**
   - O script mostrará uma tabela com os dispositivos com problema.  
   - Se estiver tudo certo, responda `S` quando for perguntado se deseja remover os dispositivos.  
   - Aguarde a remoção e a varredura (`pnputil /scan-devices`) terminarem.

### Observações importantes

- Este script faz uma ação relativamente agressiva (remover todos os dispositivos com erro listados), então sempre confira a lista mostrada antes de confirmar.  
- Caso algo não seja recriado corretamente, você ainda pode:
  - Reiniciar o computador.  
  - Abrir o Gerenciador de Dispositivos e mandar **Procurar alterações de hardware** manualmente.  
- O script **não apaga drivers**; ele apenas remove/recria os dispositivos, imitando o processo manual que você já faz.

### Ideias de extensão

- Criar uma versão que roda apenas para classes específicas (somente GPU, somente áudio, apenas ACPI).  
  - Basta ajustar o array `$allowedClasses`.  
- Agendar este script para rodar automaticamente (por exemplo, ao fazer logon) usando o **Agendador de Tarefas** do Windows.

