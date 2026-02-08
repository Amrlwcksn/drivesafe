[xml]$xml = Get-Content temp_docx/word/document.xml
$nodes = $xml.GetElementsByTagName('w:t')
foreach ($node in $nodes) {
    Write-Host $node.InnerText
}
