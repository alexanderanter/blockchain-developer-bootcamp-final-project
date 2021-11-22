import { PageHeader } from "antd";
import React from "react";

// displays a page header

export default function Header() {
  return (
    <a href="/" /*target="_blank" rel="noopener noreferrer"*/>
      <PageHeader
        title="DCA DAPP"
        subTitle="Buy WETH on a regular basis with minimum gas costs pooled together with others"
        style={{ cursor: "pointer" }}
      />
    </a>
  );
}
